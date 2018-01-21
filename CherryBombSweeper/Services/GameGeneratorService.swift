//
//  GameServices.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

typealias GenerateNewGameCompletionHandler = (_ newGame: Game) -> Void
typealias GenerateMineFieldCompletionHandler = (_ mineField: MineField) -> Void

class GameGeneratorService: NSObject {
    static let shared = GameGeneratorService()
    
    var gameOptions: GameOptions
    var preloadedGame: Game?
    
    private let generatorQueue: DispatchQueue = DispatchQueue(label: "gameGeneratorQueue", qos: .userInitiated)
    
    fileprivate override init() {
        self.gameOptions = GameOptions()
    }
    
    func preloadGame(forced: Bool = false) {
        DispatchQueue.global(qos: .utility).async {
            if forced || self.preloadedGame == nil {
                self.generateGame { (newGame) in
                    self.preloadedGame = newGame
                }
            }
        }
    }
    
    func generateNewGame(completionHandler: @escaping GenerateNewGameCompletionHandler) {
        self.generatorQueue.async {
            if let preloadedGame = self.preloadedGame,
                preloadedGame.mineField.rows == self.gameOptions.rowCount,
                preloadedGame.mineField.columns == self.gameOptions.columnCount,
                preloadedGame.mineField.mines == self.gameOptions.minesCount {
                // return preloaded
                completionHandler(preloadedGame)
            } else {
                self.generateGame { (newGame) in
                    completionHandler(newGame)
                }
            }
            
            self.preloadedGame = nil
        }
    }
    
    private func generateGame(completionHandler: @escaping GenerateNewGameCompletionHandler) {
        self.generateMineField { [weak self, completionHandler] (mineField) in
            guard let `self` = self else { return }
            
            let newGame = Game(mineField: mineField, gameOptions: self.gameOptions)
            
            completionHandler(newGame)
        }
    }
    
    private func generateMineField(completionHandler: @escaping GenerateMineFieldCompletionHandler) {
        let rows = self.gameOptions.rowCount
        let columns = self.gameOptions.columnCount
        let mines = self.gameOptions.minesCount
        
        let mineField = MineField.constructAndPopulateMineField(rows: rows, columns: columns, mines: mines)
        
        completionHandler(mineField)
    }
}
