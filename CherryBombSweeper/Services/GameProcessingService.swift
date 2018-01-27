//
//  GameProcessingService.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/17/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

protocol GameStatusListener {
    func onCellReveal(_ revealedCells: Set<Int>) -> Void
    func onCellHighlight(_ highlightedCells: Set<Int>) -> Void
    func onCellFlagged(_ flaggedCell: Int) -> Void
    func onCellUnflagged(_ unflaggedCell: Int) -> Void
    func onCellExploded(_ explodedCell: Int, otherBombCells: Set<Int>, wrongFlaggedCells: Set<Int>) -> Void
    func onGameCompleted() -> Void
}

class GameProcessingService {
    
    private typealias CellRevealHandler = (_ revealedCells: Set<Int>) -> Void
    
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
                    self.tap(at: cell)
                case .flag:
                    self.flag(at: cell)
                }
            }
        }
    }
    
    private func tap(at cell: Cell) {
        if cell.state == .flagged {
            self.flag(at: cell)
        } else if cell.state == .revealed, !cell.isEmpty {
            self.probe(at: cell)
        } else if cell.hasBomb {
            self.explode(at: cell)
        } else {
            self.reveal(at: cell.index) { (revealedCells) in
                self.gameListener?.onCellReveal(revealedCells)
            }
        }
    }
    
    private func reveal(at cellIndex: Int, revealCellHandler: @escaping CellRevealHandler) {
        self.processingQueue.async {
            if let cell = self.currentGame?.mineField.getCell(at: cellIndex) {
                
                // process reveal this single cell
                self.processRevealCell(at: cellIndex)
                
                if cell.connectedEmptyCluster.isEmpty {
                    revealCellHandler(Set([cell.index]))
                } else {
                    // Since it has a connected empty cell cluster, reveal those too
                    self.processRevealCell(cluster: cell.connectedEmptyCluster)
                    
                    revealCellHandler(cell.connectedEmptyCluster)
                }
            }
        }
    }
    
    private func processRevealCell(cluster indicesCluster: Set<Int>) {
        self.processingQueue.async {
            for cellIndex in indicesCluster {
                self.processRevealCell(at: cellIndex)
            }
        }
    }
    
    private func processRevealCell(at cellIndex: Int) {
        if let currentGame = self.currentGame, let cell = currentGame.mineField.getCell(at: cellIndex) {
            guard cell.state == .untouched else { return }
            
            if cell.hasBomb {
                self.explode(at: cell)
            } else {
                cell.state = .revealed
                
                currentGame.mineField.updateCell(cell)
                currentGame.mineField.safeCellsCount -= 1
                
                if currentGame.mineField.safeCellsCount == 0 {
                    gameListener?.onGameCompleted()
                }
            }
        }
    }
    
    private func explode(at cell: Cell) {
        guard cell.state == .untouched else { return }
        
        cell.state = .exploded
        
        var otherBombCellIds: Set<Int> = []
        var wrongFlaggedIds: Set<Int> = []
        
        if let game = self.currentGame {
            game.mineField.updateCell(cell)
            
            otherBombCellIds = game.mineField.bombCellIndices
            otherBombCellIds.remove(cell.index)
            
            for cellId in otherBombCellIds {
                if let cell = game.mineField.getCell(at: cellId), cell.state == .untouched, cell.hasBomb {
                    cell.state = .showBomb
                    game.mineField.updateCell(cell)
                }
            }
            
            for flaggedCellId in game.flaggedCellIndices {
                if let cell = game.mineField.getCell(at: flaggedCellId), cell.state == .flagged, !cell.hasBomb {
                    cell.state = .wrongBomb
                    game.mineField.updateCell(cell)
                    wrongFlaggedIds.insert(flaggedCellId)
                }
            }
        }
        
        self.gameListener?.onCellExploded(cell.index, otherBombCells: otherBombCellIds, wrongFlaggedCells: wrongFlaggedIds)
    }
    
    private func probe(at cell: Cell) {
        guard let mineField = self.currentGame?.mineField, cell.state == .revealed, !cell.isEmpty else { return }
        
        let flaggedCellIDs = cell.adjacentCellIndices.filter {
            mineField.getCell(at: $0)?.state == .flagged
        }
        
        let untouchedCellIDs = cell.adjacentCellIndices.filter {
            mineField.getCell(at: $0)?.state == .untouched
        }
        
        if flaggedCellIDs.count >= cell.adjacentBombs {
            for cellId in untouchedCellIDs {
                self.reveal(at: cellId) { (revealedCells) in
                    self.gameListener?.onCellReveal(revealedCells)
                }
            }
        } else {
            // flash the cells
            for cellId in untouchedCellIDs {
                if let cell = mineField.getCell(at: cellId) {
                    cell.state = .highlight
                    self.currentGame?.mineField.updateCell(cell)
                }
            }
            
            self.gameListener?.onCellHighlight(Set(untouchedCellIDs))
        }
    }
    
    private func flag(at cell: Cell) {
        switch cell.state {
        case .revealed:
            if !cell.isEmpty {
                self.probe(at: cell)
            }
        case .untouched:
            cell.state = .flagged
            if let currentGame = self.currentGame {
                if cell.hasBomb {
                    currentGame.mineField.unmarkedBombs -= 1
                }
                
                currentGame.mineField.updateCell(cell)
                currentGame.minesRemaining -= 1
                currentGame.flaggedCellIndices.insert(cell.index)
            }
            
            self.gameListener?.onCellFlagged(cell.index)
            
            self.processingQueue.async {
                if self.currentGame?.mineField.unmarkedBombs == 0 {
                    self.gameListener?.onGameCompleted()
                }
            }
        case .flagged:
            cell.state = .untouched
            if let currentGame = self.currentGame {
                if cell.hasBomb {
                    currentGame.mineField.unmarkedBombs += 1
                }
                
                currentGame.mineField.updateCell(cell)
                currentGame.minesRemaining += 1
                currentGame.flaggedCellIndices.remove(cell.index)
            }
            
            self.gameListener?.onCellUnflagged(cell.index)
        default:
            break
        }
    }
}
