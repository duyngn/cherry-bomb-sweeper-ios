//
//  GameModel.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

enum GameState {
    case new
    case inProgress
    case paused
    case lost
    case win
}

class Game {
    var gameOptions: GameOptions = GameServices.shared.gameOptions
    var mineField: MineField
    var state: GameState = .new
    
    init(mineField: MineField = MineField(), gameOptions: GameOptions = GameServices.shared.gameOptions) {
        self.mineField = mineField
        self.gameOptions = gameOptions
    }
}
