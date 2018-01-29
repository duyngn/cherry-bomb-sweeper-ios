//
//  GameOptions.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

class GameOptions: NSObject, NSCoding {
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
    
    required convenience init(coder aDecoder: NSCoder) {
        let rowCount = aDecoder.decodeInteger(forKey: "rowCount")
        let columnCount = aDecoder.decodeInteger(forKey: "columnCount")
        let minesCount = aDecoder.decodeInteger(forKey: "minesCount")
        
        self.init(rowCount: rowCount, columnCount: columnCount, minesCount: minesCount)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.rowCount, forKey: "rowCount")
        aCoder.encode(self.columnCount, forKey: "columnCount")
        aCoder.encode(self.minesCount, forKey: "minesCount")
    }
}
