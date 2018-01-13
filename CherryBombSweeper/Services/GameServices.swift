//
//  GameServices.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

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
}
