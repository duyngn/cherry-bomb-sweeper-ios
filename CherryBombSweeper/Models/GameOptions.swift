//
//  GameOptions.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

enum ToggleState {
    case on
    case off
}

class GameOptions {
    var rowCount: Int
    var columnCount: Int
    var minesCount: Int
    
    var musicState: ToggleState = .on
    
    init(rowCount: Int = 9, columnCount: Int = 9, minesCount: Int = 10) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.minesCount = minesCount
    }
}
