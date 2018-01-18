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
    
    case highlight
    case showBomb
}

class Cell {
    var state: CellState = .untouched
    
    private(set) var index: Int
    private(set) var fieldCoord: FieldCoord = FieldCoord(row: 0, column: 0)
    
    var adjacentCellIndices: Set<Int> = []
    var connectedEmptyCluster: Set<Int> = []
    
    var hasBomb: Bool = false
    var adjacentBombs: Int = 0
    var isEmpty: Bool {
        return self.adjacentBombs == 0
    }
    
    init(index: Int = 0, row: Int = 0, column: Int = 0) {
        self.index = index
        self.fieldCoord = FieldCoord(row: row, column: column)
    }
}
