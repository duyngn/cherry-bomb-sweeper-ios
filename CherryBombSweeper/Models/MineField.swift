//
//  MineField.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/11/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

typealias FieldCoordMap = [Int: FieldCoord]
struct FieldCoord {
    var row: Int
    var column: Int
}

class MineField {
    var mines: Int = 0
    var rows: Int = 0
    var columns: Int = 0
    
    var fieldGrid: [[Cell]]
    var cellCoordMap: FieldCoordMap = [:]
    var safeCellCoordMap: FieldCoordMap = [:]
    
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
    
    func getCell(at index: Int) -> Cell? {
        guard index >= 0, index < self.cellCoordMap.count, let cellCoord = self.cellCoordMap[index] else { return nil }
        
        return self.fieldGrid[cellCoord.row][cellCoord.column]
    }
    
    func updateCell(_ cell: Cell) {
        let index = cell.id
        guard index >= 0, index < self.cellCoordMap.count, let cellCoord = self.cellCoordMap[index] else { return }
        
        self.fieldGrid[cellCoord.row][cellCoord.column] = cell
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
                
                cell.adjacentCellsCoordMap = self.findAllAdjacentCells(to: cell)
            }
        }
    }
    
    public func populateMineField(mines: Int) {
        self.mines = mines
        self.populateMineFieldRecursive(mines: self.mines, emptyCoordsMap: self.cellCoordMap)
    }
    
    private func populateMineFieldRecursive(mines: Int, emptyCoordsMap: FieldCoordMap) {
        guard mines > 0, !emptyCoordsMap.isEmpty else {
            self.safeCellCoordMap = emptyCoordsMap
            return
        }
        
        var mutatableCoordsMap = emptyCoordsMap
        var mutabableMines = mines
        
        let mapKeys = Array(mutatableCoordsMap.keys)
        let randomKeyIndex: Int = Int(arc4random_uniform(UInt32(mapKeys.count)))
        let randomKey = mapKeys[randomKeyIndex]
        
        if let randomCoord = mutatableCoordsMap[randomKey] {
            self.fieldGrid[randomCoord.row][randomCoord.column].hasBomb = true
            self.incrementBombCountsInAdjacentCells(to: self.fieldGrid[randomCoord.row][randomCoord.column])
            
            mutatableCoordsMap.removeValue(forKey: randomKey)
            mutabableMines -= 1
        }
        
        self.populateMineFieldRecursive(mines: mutabableMines, emptyCoordsMap: mutatableCoordsMap)
    }
    
    private func incrementBombCountsInAdjacentCells(to cell: Cell) {
        let ajacentCellsMap = self.findAllAdjacentCells(to: cell)
        
        for fieldCoord in ajacentCellsMap.values {
            self.fieldGrid[fieldCoord.row][fieldCoord.column].adjacentBombs += 1
        }
    }
    
    private func findAllAdjacentCells(to cell: Cell) -> FieldCoordMap {
        let row = cell.fieldCoord.row
        let col = cell.fieldCoord.column
        
        var adjacentCellsMap: FieldCoordMap = [:]
        
        // Assign adjacent rows and columns if they exist
        let rowAbove: Int? = (row - 1 >= 0) ? row - 1 : nil
        let rowBelow: Int? = (row + 1 < self.rows) ? row + 1 : nil
        let colLeft: Int? = (col - 1 >= 0) ? col - 1 : nil
        let colRight: Int? = (col + 1 < self.columns) ? col + 1 : nil
        
        // Row above
        if let rowAbove = rowAbove {
            if let colLeft = colLeft {
                // top left
                let cell = self.fieldGrid[rowAbove][colLeft]
                adjacentCellsMap[cell.id] = cell.fieldCoord
            }
            
            // top center
            let cell = self.fieldGrid[rowAbove][col]
            adjacentCellsMap[cell.id] = cell.fieldCoord
            
            if let colRight = colRight {
                // top right
                let cell = self.fieldGrid[rowAbove][colRight]
                adjacentCellsMap[cell.id] = cell.fieldCoord
            }
        }
        
        // Same row
        if let colLeft = colLeft {
            // Left
            let cell = self.fieldGrid[row][colLeft]
            adjacentCellsMap[cell.id] = cell.fieldCoord
        }
        
        if let colRight = colRight {
            // Right
            let cell = self.fieldGrid[row][colRight]
            adjacentCellsMap[cell.id] = cell.fieldCoord
        }
        
        // Row below
        if let rowBelow = rowBelow {
            if let colLeft = colLeft {
                // below left
                let cell = self.fieldGrid[rowBelow][colLeft]
                adjacentCellsMap[cell.id] = cell.fieldCoord
            }
            
            // below center
            let cell = self.fieldGrid[rowBelow][col]
            adjacentCellsMap[cell.id] = cell.fieldCoord
            
            if let colRight = colRight {
                // below right
                let cell = self.fieldGrid[rowBelow][colRight]
                adjacentCellsMap[cell.id] = cell.fieldCoord
            }
        }
        
        return adjacentCellsMap
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
