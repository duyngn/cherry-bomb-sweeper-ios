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
    func onCellExploded(_ explodedCell: Int) -> Void
    func onGameCompleted() -> Void
}

typealias CellRevealHandler = (_ revealedCells: Set<Int>) -> Void

class GameProcessingService: NSObject {
    
    static let shared = GameProcessingService()
    
    private var gameListener: GameStatusListener?
    private var currentGame: Game?
    
    private let processingQueue: DispatchQueue = DispatchQueue(label: "gameProcessingQueue", qos: .userInitiated)
    
    fileprivate override init() {}
    
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
        if let cell = self.currentGame?.mineField.getCell(at: cellIndex) {
            guard cell.state == .untouched else { return }
            
            if cell.hasBomb {
                self.explode(at: cell)
            } else {
                cell.state = .revealed
                
                self.currentGame?.mineField.updateCell(cell)
                self.currentGame?.mineField.safeCellsCount -= 1
                
                if self.currentGame?.mineField.safeCellsCount == 0 {
                    self.gameListener?.onGameCompleted()
                }
            }
        }
    }
    
    private func explode(at cell: Cell) {
        guard cell.state == .untouched else { return }
        
        cell.state = .exploded
        
        self.currentGame?.mineField.updateCell(cell)
        
        self.gameListener?.onCellExploded(cell.index)
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
            self.currentGame?.mineField.updateCell(cell)
            
            self.gameListener?.onCellFlagged(cell.index)
        case .flagged:
            cell.state = .untouched
            self.currentGame?.mineField.updateCell(cell)
            
            self.gameListener?.onCellUnflagged(cell.index)
        default:
            break
        }
    }
}
