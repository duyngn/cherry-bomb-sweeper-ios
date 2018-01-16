//
//  CellModel.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

enum CellState {
    case untouched
    case revealed
    case flagged
    case exploded
}

class Cell {
    private(set) var id: Int
    private(set) var fieldCoord: FieldCoord = FieldCoord(row: 0, column: 0)
    var state: CellState = .untouched
    
    var hasBomb: Bool = false
    var adjacentBombs: Int = 0
    
    var isEmpty: Bool {
        return self.adjacentBombs == 0
    }
    
    var adjacentCellsCoordMap: FieldCoordMap = [:]
    
    init(id: Int = 0, row: Int = 0, column: Int = 0) {
        self.id = id
        self.fieldCoord = FieldCoord(row: row, column: column)
    }
}
