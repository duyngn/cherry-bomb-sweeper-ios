//
//  GameOptions.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

struct GameOptions: Codable {
    var rowCount: Int
    var columnCount: Int
    var minesCount: Int
    
    init(rowCount: Int = Constants.defaultRows,
         columnCount: Int = Constants.defaultRows,
         minesCount: Int = Constants.defaultMines) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.minesCount = minesCount
    }
}
