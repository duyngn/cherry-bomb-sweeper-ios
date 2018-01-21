//
//  MineField.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/11/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

struct FieldCoord {
    var row: Int
    var column: Int
}

typealias FieldCoordMap = [Int: FieldCoord]

class MineField {
    var mines: Int = 0
    var rows: Int = 0
    var columns: Int = 0
    
    var fieldMatrix: [[Cell]]
    var cellIndexToCoordMap: FieldCoordMap = [:]
    
    var bombCellIndices: Set<Int> = []
    var safeCellIndices: Set<Int> = []
    
    var safeCellsCount: Int = 0
    
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
                fieldGrid[row].append(Cell(index: index, row: row, column: column))
                
                index += 1
            }
        }
        
        return MineField(fieldGrid: fieldGrid, rows: rows, columns: columns)
    }
    
    init(fieldGrid: [[Cell]] = [], mines: Int = 0, rows: Int = 0, columns: Int = 0) {
        self.mines = mines
        self.rows = rows
        self.columns = columns
        self.fieldMatrix = fieldGrid
        
        self.generateFieldMap()
    }
    
    func getCell(at index: Int) -> Cell? {
        guard let cellCoord = self.cellIndexToCoordMap[index] else { return nil }
        
        return self.fieldMatrix[cellCoord.row][cellCoord.column]
    }
    
    func getCell(at fieldCoord: FieldCoord) -> Cell? {
        guard self.isValidFieldCoord(fieldCoord) else { return nil }
        
        return self.fieldMatrix[fieldCoord.row][fieldCoord.column]
    }
    
    func updateCell(_ cell: Cell) {
        guard let cellCoord = self.cellIndexToCoordMap[cell.index] else { return }
        
        self.fieldMatrix[cellCoord.row][cellCoord.column] = cell
    }
    
    private func isValidFieldCoord(_ fieldCoord: FieldCoord) -> Bool {
        return fieldCoord.row >= 0
            && fieldCoord.row < self.rows
            && fieldCoord.column >= 0
            && fieldCoord.column < self.columns
    }
    
    private func generateFieldMap() {
        self.cellIndexToCoordMap.removeAll()
        
        if self.fieldMatrix.isEmpty {
            return
        }
        
        for row in 0..<rows {
            for column in 0..<columns {
                let cell = fieldMatrix[row][column]
                self.cellIndexToCoordMap[cell.index] = cell.fieldCoord
                
                cell.adjacentCellIndices = Set(self.findAllAdjacentIndices(to: cell.fieldCoord))
            }
        }
    }
    
    private func populateMineField(mines: Int) {
        self.mines = mines
        self.populateMineFieldRecursive(mines: self.mines, emptyCoordsMap: self.cellIndexToCoordMap)
        
        self.flagEmptyCellClusters(in: self.safeCellIndices)
    }
    
    private func populateMineFieldRecursive(mines: Int, emptyCoordsMap: FieldCoordMap) {
        guard mines > 0, !emptyCoordsMap.isEmpty else {
            self.safeCellIndices = Set(emptyCoordsMap.flatMap { $0.key })
            self.safeCellsCount = self.safeCellIndices.count
            return
        }
        
        var mutatableEmptyCoordsMap = emptyCoordsMap
        var mutabableMines = mines
        
        let mapKeys = Array(mutatableEmptyCoordsMap.keys)
        let randomKeyIndex: Int = Int(arc4random_uniform(UInt32(mapKeys.count)))
        let selectedKey = mapKeys[randomKeyIndex]
        
        if let selectedCoord = mutatableEmptyCoordsMap[selectedKey] {
            self.fieldMatrix[selectedCoord.row][selectedCoord.column].hasBomb = true
            self.bombCellIndices.insert(self.fieldMatrix[selectedCoord.row][selectedCoord.column].index)
            
            self.incrementBombCountsInAdjacentCells(to: selectedCoord)
            
            mutatableEmptyCoordsMap.removeValue(forKey: selectedKey)
            mutabableMines -= 1
        }
        
        self.populateMineFieldRecursive(mines: mutabableMines, emptyCoordsMap: mutatableEmptyCoordsMap)
    }
    
    private func incrementBombCountsInAdjacentCells(to fieldCoord: FieldCoord) {
        let ajacentCoords = self.findAllAdjacentCoords(to: fieldCoord)
        
        for fieldCoord in ajacentCoords {
            self.fieldMatrix[fieldCoord.row][fieldCoord.column].adjacentBombs += 1
        }
    }
    
    private func flagEmptyCellClusters(in emptyCellsPool: Set<Int>) {
        guard !emptyCellsPool.isEmpty, let cellIndex = emptyCellsPool.first else { return }
        
        var modifiedEmptyCellsPool: Set<Int> = []
        
        if let cell = self.getCell(at: cellIndex) {
            // Call this recursive function to find all the connected empty cells
            // When this returns, it will represent one set of connected empty cluster
            let connectedEmptyCluster = self.findConnectedEmptyClusterRecursive(to: cell, existingCluster: Set<Int>())
            
            // Remove the proccessed cells from the main pool
            modifiedEmptyCellsPool = emptyCellsPool.subtracting(connectedEmptyCluster)
            
            // Now flag every member cell with this cluster
            for index in connectedEmptyCluster {
                if let fieldCoord = self.cellIndexToCoordMap[index] {
                    self.fieldMatrix[fieldCoord.row][fieldCoord.column].connectedEmptyCluster = connectedEmptyCluster
                }
            }
        }
        
        // Recursively call this function again for the remaining empty cells in the pool
        self.flagEmptyCellClusters(in: modifiedEmptyCellsPool)
    }
    
    private func findConnectedEmptyClusterRecursive(to cell: Cell, existingCluster: Set<Int>) -> Set<Int> {
        guard !cell.hasBomb, !existingCluster.contains(cell.index) else {
            // Exit recursion since this cell has a bomb or it's already been checked
            return existingCluster
        }
        
        var mutatableExistingCluster = existingCluster
        
        // add this cell to the cluster
        mutatableExistingCluster.insert(cell.index)
        
        if cell.isEmpty {
            // Deeper recursion to check its neighbors
            for cellIndex in cell.adjacentCellIndices {
                if let cell = self.getCell(at: cellIndex) {
                    mutatableExistingCluster = self.findConnectedEmptyClusterRecursive(to: cell, existingCluster: mutatableExistingCluster)
                }
            }
        }
        
        return mutatableExistingCluster
    }
    
    private func findAllAdjacentIndices(to coord: FieldCoord) -> [Int] {
        let row = coord.row
        let col = coord.column
        
        var adjacentIndices: [Int] = []
        
        // Assign adjacent rows and columns if they exist
        let rowAbove: Int? = (row - 1 >= 0) ? row - 1 : nil
        let rowBelow: Int? = (row + 1 < self.rows) ? row + 1 : nil
        let colLeft: Int? = (col - 1 >= 0) ? col - 1 : nil
        let colRight: Int? = (col + 1 < self.columns) ? col + 1 : nil
        
        // Row above
        if let rowAbove = rowAbove {
            if let colLeft = colLeft {
                // top left
                adjacentIndices.append(self.fieldMatrix[rowAbove][colLeft].index)
            }
            
            // top center
            adjacentIndices.append(self.fieldMatrix[rowAbove][col].index)
            
            if let colRight = colRight {
                // top right
                adjacentIndices.append(self.fieldMatrix[rowAbove][colRight].index)
            }
        }
        
        // Same row
        if let colLeft = colLeft {
            // Left
            adjacentIndices.append(self.fieldMatrix[row][colLeft].index)
        }
        
        if let colRight = colRight {
            // Right
            adjacentIndices.append(self.fieldMatrix[row][colRight].index)
        }
        
        // Row below
        if let rowBelow = rowBelow {
            if let colLeft = colLeft {
                // below left
                adjacentIndices.append(self.fieldMatrix[rowBelow][colLeft].index)
            }
            
            // below center
            adjacentIndices.append(self.fieldMatrix[rowBelow][col].index)
            
            if let colRight = colRight {
                // below right
                adjacentIndices.append(self.fieldMatrix[rowBelow][colRight].index)
            }
        }
        
        return adjacentIndices
    }
    
    private func findAllAdjacentCoords(to coord: FieldCoord) -> [FieldCoord] {
        let row = coord.row
        let col = coord.column
        
        var adjacentCoords: [FieldCoord] = []
        
        // Assign adjacent rows and columns if they exist
        let rowAbove: Int? = (row - 1 >= 0) ? row - 1 : nil
        let rowBelow: Int? = (row + 1 < self.rows) ? row + 1 : nil
        let colLeft: Int? = (col - 1 >= 0) ? col - 1 : nil
        let colRight: Int? = (col + 1 < self.columns) ? col + 1 : nil
        
        // Row above
        if let rowAbove = rowAbove {
            if let colLeft = colLeft {
                // top left
                adjacentCoords.append(self.fieldMatrix[rowAbove][colLeft].fieldCoord)
            }
            
            // top center
            adjacentCoords.append(self.fieldMatrix[rowAbove][col].fieldCoord)
            
            if let colRight = colRight {
                // top right
                adjacentCoords.append(self.fieldMatrix[rowAbove][colRight].fieldCoord)
            }
        }
        
        // Same row
        if let colLeft = colLeft {
            // Left
            adjacentCoords.append(self.fieldMatrix[row][colLeft].fieldCoord)
        }
        
        if let colRight = colRight {
            // Right
            adjacentCoords.append(self.fieldMatrix[row][colRight].fieldCoord)
        }
        
        // Row below
        if let rowBelow = rowBelow {
            if let colLeft = colLeft {
                // below left
                adjacentCoords.append(self.fieldMatrix[rowBelow][colLeft].fieldCoord)
            }
            
            // below center
            adjacentCoords.append(self.fieldMatrix[rowBelow][col].fieldCoord)
            
            if let colRight = colRight {
                // below right
                adjacentCoords.append(self.fieldMatrix[rowBelow][colRight].fieldCoord)
            }
        }
        
        return adjacentCoords
    }
    
    func describe() -> String{
        var outputLine = ""
        for row in 0..<rows {
            for column in 0..<columns {
                if fieldMatrix[row][column].hasBomb {
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
