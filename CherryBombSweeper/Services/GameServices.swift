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
    
    fileprivate override init() {
        self.gameOptions = GameOptions()
    }
    
    func generateNewGame(completionHandler: @escaping GenerateNewGameCompletionHandler) {
        self.serviceQueue.async {
            self.generateMineField { [weak self, completionHandler] (mineField) in
                guard let `self` = self else { return }
                
                let newGame = Game(mineField: mineField, gameOptions: self.gameOptions)
                
                completionHandler(newGame)
            }
        }
    }
    
    func generateMineField(completionHandler: @escaping GenerateMineFieldCompletionHandler) {
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
    
    static func resolveUserAction(at cellIndex: Int, in mineField: MineField, with userAction: UserAction, updateCellHandler: @escaping UpdateCellHandler) {
        GameServices.shared.serviceQueue.async {
            switch userAction {
            case .reveal:
                GameServices.revealCell(at: cellIndex, in: mineField, updateCellHandler: updateCellHandler)
            case .probe:
                GameServices.probeCell(at: cellIndex, in: mineField, updateCellHandler: updateCellHandler)
            case .flag:
                GameServices.flagCell(at: cellIndex, in: mineField, updateCellHandler: updateCellHandler)
            }
        }
    }
    
    static func revealCell(at cellIndex: Int, in mineField: MineField, updateCellHandler: @escaping UpdateCellHandler) {
        GameServices.shared.serviceQueue.async {
            if let cell = mineField.getCell(at: cellIndex) {
                guard cell.state != .revealed else { return }
                
                if cell.state == .flagged {
                    cell.state = .untouched
                } else if cell.hasBomb {
                    cell.state = .exploded
                } else {
                    cell.state = .revealed
                }
                
                mineField.updateCell(cell)
                
                updateCellHandler(cell)
                
                if cell.state == .revealed, cell.isEmpty {
                    // recursive reveal
                    GameServices.revealEmptyAdjacentCells(at: cellIndex, in: mineField, updateCellHandler: updateCellHandler)
                }
            }
        }
    }
    
    static func revealEmptyAdjacentCells(at cellIndex: Int, in mineField: MineField, updateCellHandler: @escaping UpdateCellHandler) {
        GameServices.shared.serviceQueue.async {
            if let cell = mineField.getCell(at: cellIndex) {
                let adjacentCellsMap = cell.adjacentCellsCoordMap
                
                for index in adjacentCellsMap.keys {
                    if let adjacentCell = mineField.getCell(at: index), !adjacentCell.hasBomb, adjacentCell.state == .untouched {
                        GameServices.revealCell(at: index, in: mineField, updateCellHandler: updateCellHandler)
                    }
                }
            }
        }
    }
    
    static func probeCell(at cellIndex: Int, in mineField: MineField, updateCellHandler: @escaping UpdateCellHandler) {
        
    }
    
    static func flagCell(at cellIndex: Int, in mineField: MineField, updateCellHandler: @escaping UpdateCellHandler) {
        GameServices.shared.serviceQueue.async {
            if let cell = mineField.getCell(at: cellIndex) {
                guard cell.state == .untouched else { return }
                
                cell.state = .flagged
                
                mineField.updateCell(cell)
                
                updateCellHandler(cell)
            }
        }
    }
}
