//
//  MineField.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/11/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

typealias FieldCoordMap = [Int: FieldCoord]

class MineField {
    var mines: Int = 0
    var rows: Int = 0
    var columns: Int = 0
    
    var fieldGrid: [[Cell]]
    var cellCoordMap: FieldCoordMap = [:]
    
    static func constructAndPopulateMineField(rows: Int, columns: Int, mines: Int) -> MineField {
        // Construct the empty field
        let mineField = MineField.constructEmptyMineField(rows: rows, columns: columns)
        
        // populate the mines into the field
        mineField.populateMineField(mines: mines)
        
        return mineField
    }
    
    static func constructEmptyMineField(rows: Int, columns: Int) -> MineField {
        var fieldGrid: [[Cell]] = []
        var index = 0
        for row in 0..<rows {
            fieldGrid.append([])
            
            for column in 0..<columns {
                fieldGrid[row].append(Cell(id: index, row: row, column: column))
                
                index += 1
            }
        }
        
        return MineField(fieldGrid: fieldGrid, rows: rows, columns: columns)
    }
    
    init(fieldGrid: [[Cell]] = [], mines: Int = 0, rows: Int = 0, columns: Int = 0) {
        self.mines = mines
        self.rows = rows
        self.columns = columns
        self.fieldGrid = fieldGrid
        self.generateFieldMap()
    }
    
    private func generateFieldMap() {
        self.cellCoordMap.removeAll()
        
        if fieldGrid.isEmpty {
            return
        }
        
        for row in 0..<rows {
            for column in 0..<columns {
                let cell = fieldGrid[row][column]
                self.cellCoordMap[cell.id] = cell.fieldCoord
            }
        }
    }
    
    public func populateMineField(mines: Int) {
        self.mines = mines
        self.populateMineFieldRecursive(mines: self.mines, emptyCoordsMap: self.cellCoordMap)
    }
    
    private func populateMineFieldRecursive(mines: Int, emptyCoordsMap: FieldCoordMap) {
        guard mines > 0, !emptyCoordsMap.isEmpty else {
            return
        }
        
        var mutatableCoordsMap = emptyCoordsMap
        var mutabableMines = mines
        
        let mapKeys = Array(mutatableCoordsMap.keys)
        let randomKeyIndex: Int = Int(arc4random_uniform(UInt32(mapKeys.count)))
        let randomKey = mapKeys[randomKeyIndex]
        
        if let randomCoord = mutatableCoordsMap[randomKey] {
            self.fieldGrid[randomCoord.row][randomCoord.column].hasBomb = true
            self.incrementBombCountsInAdjacentCells(to: randomCoord)
            
            mutatableCoordsMap.removeValue(forKey: randomKey)
            mutabableMines -= 1
        }
        
        self.populateMineFieldRecursive(mines: mutabableMines, emptyCoordsMap: mutatableCoordsMap)
    }
    
    private func incrementBombCountsInAdjacentCells(to coord: FieldCoord) {
        let row = coord.row
        let col = coord.column
        
        // Assign adjacent rows and columns if they exist
        let rowAbove: Int? = (row - 1 >= 0) ? row - 1 : nil
        let rowBelow: Int? = (row + 1 < self.rows) ? row + 1 : nil
        let colLeft: Int? = (col - 1 >= 0) ? col - 1 : nil
        let colRight: Int? = (col + 1 < self.columns) ? col + 1 : nil
        
        // Row above
        if let rowAbove = rowAbove {
            if let colLeft = colLeft {
                // top left
                self.fieldGrid[rowAbove][colLeft].adjacentBombs += 1
            }
            
            // top center
            self.fieldGrid[rowAbove][col].adjacentBombs += 1
            
            if let colRight = colRight {
                // top right
                self.fieldGrid[rowAbove][colRight].adjacentBombs += 1
            }
        }
        
        // Same row
        if let colLeft = colLeft {
            // Left
            self.fieldGrid[row][colLeft].adjacentBombs += 1
        }
        
        if let colRight = colRight {
            // Right
            self.fieldGrid[row][colRight].adjacentBombs += 1
        }
        
        // Row below
        if let rowBelow = rowBelow {
            if let colLeft = colLeft {
                // below left
                self.fieldGrid[rowBelow][colLeft].adjacentBombs += 1
            }
            
            // below center
            self.fieldGrid[rowBelow][col].adjacentBombs += 1
            
            if let colRight = colRight {
                // below right
                self.fieldGrid[rowBelow][colRight].adjacentBombs += 1
            }
        }
    }
    
    func describe() -> String{
        var outputLine = ""
        for row in 0..<rows {
            for column in 0..<columns {
                if fieldGrid[row][column].hasBomb {
                    outputLine.append("⬛️")
                } else {
                    outputLine.append("⬜️")
                }
            }
            outputLine.append("\n")
        }
        
        print(outputLine)
        return outputLine
    }
}
