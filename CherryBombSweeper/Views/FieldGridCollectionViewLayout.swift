//
//  FieldGridCollectionViewLayout.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/18/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

protocol FieldGridLayoutDelegate: class {
    func collectionView(columnCountForFieldGrid collectionView: UICollectionView) -> Int
    func collectionView(cellDimensionForFieldGrid collectionView: UICollectionView) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, cellPaddingForIndexPath indexPath: IndexPath) -> CGFloat
}

class FieldGridCollectionViewLayout: UICollectionViewLayout {

    weak var delegate: FieldGridLayoutDelegate!
    
    fileprivate var numberOfRows = 9
    fileprivate var numberOfColumns = 9
    fileprivate var cellDimension: CGFloat = CGFloat(44)
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }
        
        let insets = collectionView.contentInset
        return (CGFloat(self.numberOfColumns) * self.cellDimension) - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }
    
    override func prepare() {
        guard self.cache.isEmpty == true, let collectionView = self.collectionView else {
            return
        }
        
        self.numberOfColumns = self.delegate.collectionView(columnCountForFieldGrid: collectionView)
        self.cellDimension = self.delegate.collectionView(cellDimensionForFieldGrid: collectionView)
        
        let columnWidth = self.contentWidth / CGFloat(self.numberOfColumns)
        let rowHeight = columnWidth
        
        var columnOffset = [CGFloat]()
        for column in 0 ..< self.numberOfColumns {
            columnOffset.append(CGFloat(column) * columnWidth)
        }
        
        var rowOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        var column = 0
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let cellPadding = self.delegate.collectionView(collectionView, cellPaddingForIndexPath: indexPath)
            
            let height = cellPadding * 2 + rowHeight
            let frame = CGRect(x: columnOffset[column], y: rowOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.cache.append(attributes)
            
            self.contentHeight = max(contentHeight, frame.maxY)
            rowOffset[column] = rowOffset[column] + height
            
            column = column < (self.numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in self.cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath.item]
    }
}
