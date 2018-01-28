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

class GameGeneratorService {
    
    var gameOptions: GameOptions = PersistableService.getGameOptions()
    private var preloadedGame: Game?
    
    init() {
        self.preloadGame()
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
        DispatchQueue.global(qos: .userInitiated).async {
            // Make sure the preloaded game matches what the current user configs are
            self.gameOptions = PersistableService.getGameOptions()
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
        self.generateMineField { [completionHandler] (mineField) in
            
            let newGame = Game(mineField: mineField)
            
            completionHandler(newGame)
        }
    }
    
    private func generateMineField(completionHandler: @escaping GenerateMineFieldCompletionHandler) {
        self.gameOptions = PersistableService.getGameOptions()
        
        let mineField = MineField.constructAndPopulateMineField(
            rows: gameOptions.rowCount,
            columns: gameOptions.columnCount,
            mines: gameOptions.minesCount)
        
        completionHandler(mineField)
    }
}
