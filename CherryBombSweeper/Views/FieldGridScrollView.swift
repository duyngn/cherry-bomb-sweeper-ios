//
//  FieldGridScrollView.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/19/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class FieldGridScrollView: UIScrollView {
    fileprivate var fieldGridCollection: FieldGridCollectionView?

    private var minScaleFactor: CGFloat = GameGeneralService.Constant.defaultMinScaleFactor
    
//    private var maxContentOffset: CGFloat = 0
    
    private var cellTapHandler: CellTapHandler?
    
    private var rowCount: Int = 0
    private var columnCount: Int = 0
    private var fieldWidth: CGFloat = 0
    private var fieldHeight: CGFloat = 0
    private var modifiedIndexPaths: Set<IndexPath> = []
    
    lazy private var setUpOnce: Void = {
        self.delegate = self
        
        self.isScrollEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        let fieldGrid = FieldGridCollectionView(frame: self.frame, collectionViewLayout: FieldGridCollectionViewLayout())
        fieldGrid.layer.borderWidth = GameGeneralService.Constant.fieldBorderWidth
        fieldGrid.layer.borderColor = UIColor.black.cgColor
        self.fieldGridCollection = fieldGrid
        
        fieldGrid.isHidden = true
        
        self.addSubview(fieldGrid)
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let _ = setUpOnce
    }
    
    func setupFieldGrid(rows: Int, columns: Int,
                        dataSource: UICollectionViewDataSource,
                        cellTapHandler: @escaping CellTapHandler,
                        completionHandler: FieldSetupCompletionHandler?) {
        
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        if rows == self.rowCount, columns == self.columnCount {
            // Dimension didn't change, so just reset it
            fieldGridCollection.dataSource = dataSource
            fieldGridCollection.cellTapHandler = cellTapHandler
            
            // Show and reload only what's been affected
            fieldGridCollection.isHidden = false
            fieldGridCollection.reloadItems(at: Array(self.modifiedIndexPaths))
            self.modifiedIndexPaths.removeAll()
            
            completionHandler?(self.fieldWidth, self.fieldHeight)
            
            DispatchQueue.main.async {
                self.setZoomScale(1.0, animated: true)
                self.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
            return
        }
        
        self.rowCount = rows
        self.columnCount = columns
        self.modifiedIndexPaths.removeAll()
        
        fieldGridCollection.setupFieldGrid(rows: rows, columns: columns, dataSource: dataSource, cellTapHandler: cellTapHandler) { [weak self] (fieldWidth, fieldHeight) in
            guard let `self` = self else { return }
            
            self.fieldWidth = fieldWidth
            self.fieldHeight = fieldHeight
            
            let windowWidth = self.frame.width
            let windowHeight = self.frame.height
    
            // Figure out which dimension is wider than screen when normalized, that dimension would determine the mininum scale factor
            // to fit the entire field into the container
            let screenAspect = windowWidth / windowHeight
            let fieldAspect = fieldWidth / fieldHeight
            
            if fieldAspect > screenAspect {
                // width is wider
                self.minScaleFactor = windowWidth / fieldWidth
//                self.maxContentOffset = windowHeight - (self.minScaleFactor * fieldHeight)
            } else {
                // height is taller
                self.minScaleFactor = windowHeight / fieldHeight
            }
            
            self.minimumZoomScale = self.minScaleFactor
            self.maximumZoomScale = GameGeneralService.Constant.defaultMaxScaleFactor
            self.contentSize = CGSize(width: fieldWidth, height: fieldHeight)

            // Show and reload
            fieldGridCollection.isHidden = false
            fieldGridCollection.reloadData()
            
            completionHandler?(fieldWidth, fieldHeight)
            
            DispatchQueue.main.async {
                self.setZoomScale(1.0, animated: true)
                self.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
    }
    
    func updateCells(at indexPaths: [IndexPath]) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        // keep track of which cell has been affected
        self.modifiedIndexPaths = self.modifiedIndexPaths.union(indexPaths)
        
        fieldGridCollection.reloadItems(at: indexPaths)
    }
}

extension FieldGridScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.fieldGridCollection
    }
}

extension FieldGridScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

