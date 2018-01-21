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
    func collectionView(viewWindowForFieldGrid collectionView: UICollectionView) -> CGRect?
}

extension FieldGridLayoutDelegate {
    func collectionView(columnCountForFieldGrid collectionView: UICollectionView) -> Int {
        return GameGeneralService.Constant.defaultColumns
    }
    
    func collectionView(cellDimensionForFieldGrid collectionView: UICollectionView) -> CGFloat {
        return GameGeneralService.Constant.defaultCellDimension
    }
    
    func collectionView(cellSpacingForFieldGrid collectionView: UICollectionView) -> CGFloat {
        return GameGeneralService.Constant.cellSpacing
    }
    
    func collectionView(viewWindowForFieldGrid collectionView: UICollectionView) -> CGRect? {
        return nil
    }
}

class FieldGridCollectionViewLayout: UICollectionViewLayout, FieldGridLayoutDelegate {    
    weak var delegate: FieldGridLayoutDelegate?
    
    private var numberOfColumns = GameGeneralService.Constant.defaultColumns
    private var cellDimension: CGFloat = 0
    private var cellSpacing: CGFloat = 0
    
    private var itemAttributesCache = [UICollectionViewLayoutAttributes]()
    
//    private var containerRect: CGRect?
    
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        return (CGFloat(self.numberOfColumns) * (self.cellDimension + self.cellSpacing)) - self.cellSpacing
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }
    
    override func prepare() {
        guard self.itemAttributesCache.isEmpty == true, let collectionView = self.collectionView else {
            return
        }
        
        self.numberOfColumns = (self.delegate ?? self).collectionView(columnCountForFieldGrid: collectionView)
        self.cellDimension = (self.delegate ?? self).collectionView(cellDimensionForFieldGrid: collectionView)
        self.cellSpacing = (self.delegate ?? self).collectionView(cellSpacingForFieldGrid: collectionView)
        
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
            
            let frame = CGRect(x: columnOffset[column], y: rowOffset[column], width: columnWidth, height: rowHeight)
            let insetFrame = frame.insetBy(dx: self.cellSpacing, dy: self.cellSpacing)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.itemAttributesCache.append(attributes)
            
            self.contentHeight = max(contentHeight, frame.maxY) + self.cellSpacing
            rowOffset[column] = rowOffset[column] + rowHeight
            
            column = column < (self.numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        var windowRect = rect
//
//        if let collectionView = self.collectionView, let delegate = self.delegate,
//            let containerRect = delegate.collectionView(viewWindowForFieldGrid: collectionView) {
//            windowRect = containerRect.intersection(rect)
//        }
        
        return self.itemAttributesCache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.itemAttributesCache[indexPath.item]
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        itemAttributesCache = []
        self.contentHeight = 0
    }
}
