//
//  GameProcessingService.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/17/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

protocol GameStatusListener {
    func onCellReveal(_ revealedCells: [Int]) -> Void
    func onCellHighlight(_ highlightedCells: [Int]) -> Void
    func onCellFlagged(_ flaggedCell: Int) -> Void
    func onCellUnflagged(_ unflaggedCell: Int) -> Void
    func onCellExploded(_ explodedCell: Int) -> Void
    func onGameCompleted() -> Void
}

typealias CellRevealHandler = (_ revealedCells: [Int]) -> Void

class GameProcessingService: NSObject {
    
    static let shared = GameProcessingService()
    
    private var gameListener: GameStatusListener?
    private var currentGame: Game?
    
    private let processingQueue: DispatchQueue = DispatchQueue(label: "gameProcessingQueue", qos: .userInitiated)
    
    func registerListener(_ listener: GameStatusListener) {
        self.gameListener = listener
    }
    
    func resolveUserAction(at cellIndex: Int, in game: Game, with userAction: UserAction) {
        self.processingQueue.async {
            self.currentGame = game
            
            if let cell = game.mineField.getCell(at: cellIndex) {
                switch userAction {
                case .tap:
                    self.tapCell(at: cell)
                case .flag:
                    self.flagCell(at: cell)
                }
            }
        }
    }
    
    private func tapCell(at cell: Cell) {
        if cell.state == .flagged {
            self.flagCell(at: cell)
        } else if cell.state == .revealed, !cell.isEmpty {
            self.probeCell(at: cell)
        } else if cell.hasBomb {
            self.explodeCell(at: cell)
        } else {
            self.revealCell(at: cell.id) { (revealedCells) in
                self.gameListener?.onCellReveal(revealedCells)
            }
        }
    }
    
    private func revealCell(at cellIndex: Int, revealCellHandler: @escaping CellRevealHandler) {
        self.processingQueue.async {
            if let cell = self.currentGame?.mineField.getCell(at: cellIndex) {
                
                guard cell.state == .untouched else { return }
                
                if cell.hasBomb {
                    self.explodeCell(at: cell)
                } else {
                    cell.state = .revealed
                    
                    self.currentGame?.mineField.updateCell(cell)
                    self.currentGame?.mineField.safeCellsCount -= 1
                    
                    if self.currentGame?.mineField.safeCellsCount == 0 {
                        self.gameListener?.onGameCompleted()
                    }
                    
                    let revealedCell: [Int] = [cell.id]
                    
                    if cell.isEmpty {
                        
                        revealCellHandler(revealedCell)
                        
                        self.revealEmptyAdjacentCells(to: cell, revealCellHandler: revealCellHandler)
                    } else {
                        revealCellHandler(revealedCell)
                    }
                }
            }
        }
    }
    
    private func revealEmptyAdjacentCells(to cell: Cell, revealCellHandler: @escaping CellRevealHandler) {
        let emptyCellsId = cell.adjacentCellsCoordMap.map{ (cellId, _) in return cellId }.filter {
            if let cell = self.currentGame?.mineField.getCell(at: $0), !cell.hasBomb, cell.state == .untouched {
                return true
            }
            return false
        }
        
        for cellId in emptyCellsId {
            self.revealCell(at: cellId, revealCellHandler: revealCellHandler)
        }
    }
    
    private func explodeCell(at cell: Cell) {
        guard cell.state == .untouched else { return }
        
        cell.state = .exploded
        
        self.currentGame?.mineField.updateCell(cell)
        
        self.gameListener?.onCellExploded(cell.id)
    }
    
    private func probeCell(at cell: Cell) {
        guard let mineField = self.currentGame?.mineField, cell.state == .revealed, !cell.isEmpty else { return }
        
        let flaggedCellIDs = cell.adjacentCellsCoordMap.map{ (cellId, _) in return cellId }.filter {
            mineField.getCell(at: $0)?.state == .flagged
        }
        
        let untouchedCellIDs = cell.adjacentCellsCoordMap.map{ (cellId, _) in return cellId }.filter {
            mineField.getCell(at: $0)?.state == .untouched
        }
        
        if flaggedCellIDs.count >= cell.adjacentBombs {
            for cellId in untouchedCellIDs {
                self.revealCell(at: cellId) { (revealedCells) in
                    self.gameListener?.onCellReveal(revealedCells)
                }
            }
        } else {
            // flash the cells
            self.gameListener?.onCellHighlight(untouchedCellIDs)
        }
    }
    
    private func flagCell(at cell: Cell) {
        switch cell.state {
        case .revealed:
            if !cell.isEmpty {
                self.probeCell(at: cell)
            }
        case .untouched:
            cell.state = .flagged
            self.currentGame?.mineField.updateCell(cell)
            
            self.gameListener?.onCellFlagged(cell.id)
        case .flagged:
            cell.state = .untouched
            self.currentGame?.mineField.updateCell(cell)
            
            self.gameListener?.onCellUnflagged(cell.id)
        default:
            break
        }
    }
}
