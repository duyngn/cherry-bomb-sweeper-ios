//
//  GameServices.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

typealias UpdateCellHandler = (_ modifiedCell: Cell) -> Void

class GameServices: NSObject {
    typealias GenerateNewGameCompletionHandler = (_ newGame: Game) -> Void
    typealias GenerateMineFieldCompletionHandler = (_ mineField: MineField) -> Void
    
    static let shared = GameServices()
    
    private let serviceQueue: DispatchQueue = DispatchQueue(label: "gameServiceQueue")
    
    var gameOptions: GameOptions
    var currentGame: Game?
    var preloadedGame: Game?
    
    fileprivate override init() {
        self.gameOptions = GameOptions()
    }
    
    func preloadGame(forced: Bool = false) {
        self.serviceQueue.async {
            if forced || self.preloadedGame == nil {
                self.generateGame { (newGame) in
                    // Can ignore this handler since newGame was already captured
                    self.preloadedGame = newGame
                }
            }
        }
    }
    
    func generateNewGame(completionHandler: @escaping GenerateNewGameCompletionHandler) {
        self.serviceQueue.async {
            if let preloadedGame = self.preloadedGame {
                // return preloaded
                completionHandler(preloadedGame)
                
                // now preload another one
                self.preloadedGame = nil
                self.preloadGame()
            } else {
                self.generateGame { (newGame) in
                    completionHandler(newGame)
                    
                    // Since we didn't have a game preloaded, let's preload now
                    self.preloadGame()
                }
            }
        }
    }
    
    private func generateGame(completionHandler: @escaping GenerateNewGameCompletionHandler) {
        self.serviceQueue.async {
            self.generateMineField { [weak self, completionHandler] (mineField) in
                guard let `self` = self else { return }
                
                let newGame = Game(mineField: mineField, gameOptions: self.gameOptions)
                
                completionHandler(newGame)
            }
        }
    }
    
    private func generateMineField(completionHandler: @escaping GenerateMineFieldCompletionHandler) {
        self.serviceQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            let rows = self.gameOptions.rowCount
            let columns = self.gameOptions.columnCount
            let mines = self.gameOptions.minesCount
            
            // Construct the empty field
            let mineField = MineField.constructAndPopulateMineField(rows: rows, columns: columns, mines: mines)
            
            completionHandler(mineField)
        }
    }
    
    // GAME ACTITIVITES
    
    func resolveUserAction(at cellIndex: Int, in game: Game, with userAction: UserAction, updateCellHandler: @escaping UpdateCellHandler) {
        self.serviceQueue.async {
            self.currentGame = game
            
            if let cell = game.mineField.getCell(at: cellIndex) {
                switch userAction {
                case .tap:
                    self.tapCell(at: cell, updateCellHandler: updateCellHandler)
                case .flag:
                    self.flagCell(at: cell, updateCellHandler: updateCellHandler)
                }
            }
        }
    }
    
    private func tapCell(at cell: Cell, updateCellHandler: @escaping UpdateCellHandler) {
        if cell.state == .flagged {
            self.flagCell(at: cell, updateCellHandler: updateCellHandler)
        } else if cell.state == .revealed, !cell.isEmpty {
            self.probeCell(at: cell, updateCellHandler: updateCellHandler)
        } else if cell.hasBomb {
            self.explodeCell(at: cell, updateCellHandler: updateCellHandler)
        } else {
            self.revealCell(at: cell.id, updateCellHandler: updateCellHandler)
        }
    }
    
    private func revealCell(at cellIndex: Int, updateCellHandler: @escaping UpdateCellHandler) {
        self.serviceQueue.async {
            if let cell = self.currentGame?.mineField.getCell(at: cellIndex) {
                
                guard cell.state == .untouched else { return }
                
                if cell.hasBomb {
                    self.explodeCell(at: cell, updateCellHandler: updateCellHandler)
                } else {
                    cell.state = .revealed
                    
                    self.currentGame?.mineField.updateCell(cell)
                    
                    updateCellHandler(cell)
                    
                    if cell.isEmpty {
                        // recursive reveal
                        self.revealEmptyAdjacentCells(to: cell, updateCellHandler: updateCellHandler)
                    }
                }
            }
        }
    }
    
    private func revealEmptyAdjacentCells(to cell: Cell, updateCellHandler: @escaping UpdateCellHandler) {
        let emptyCellsCoordMap = cell.adjacentCellsCoordMap.filter {
            if let cell = self.currentGame?.mineField.getCell(at: $0.key), !cell.hasBomb, cell.state == .untouched {
                return true
            }
            return false
        }
        
        for cellCoordMap in emptyCellsCoordMap {
            self.revealCell(at: cellCoordMap.key, updateCellHandler: updateCellHandler)
        }
    }
    
    private func explodeCell(at cell: Cell, updateCellHandler: @escaping UpdateCellHandler) {
        guard cell.state == .untouched else { return }
        
        cell.state = .exploded
        
        self.currentGame?.mineField.updateCell(cell)
        
        updateCellHandler(cell)
    }
    
    private func probeCell(at cell: Cell, updateCellHandler: @escaping UpdateCellHandler) {
        guard let mineField = self.currentGame?.mineField, cell.state == .revealed, !cell.isEmpty else { return }
        
        let flaggedCells = cell.adjacentCellsCoordMap.filter {
            mineField.getCell(at: $0.key)?.state == .flagged
        }
        
        if flaggedCells.count >= cell.adjacentBombs {
            let untouchedCells = cell.adjacentCellsCoordMap.filter {
                mineField.getCell(at: $0.key)?.state == .untouched
            }
            
            for cell in untouchedCells {
                self.revealCell(at: cell.key, updateCellHandler: updateCellHandler)
            }
        } else {
            // flash the cells
        }
    }
    
    private func flagCell(at cell: Cell, updateCellHandler: @escaping UpdateCellHandler) {
        switch cell.state {
        case .revealed:
            if !cell.isEmpty {
                self.probeCell(at: cell, updateCellHandler: updateCellHandler)
            }
        case .untouched, .flagged:
            cell.state = (cell.state == .flagged) ? .untouched : .flagged
            self.currentGame?.mineField.updateCell(cell)
            updateCellHandler(cell)
        default:
            break
        }
    }
}
