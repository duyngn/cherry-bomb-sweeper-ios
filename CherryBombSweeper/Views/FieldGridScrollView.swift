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

    private var minScaleFactor: CGFloat = Constants.defaultMinScaleFactor
    
    private var rowCount: Int = 0
    private var columnCount: Int = 0
    private var fieldWidth: CGFloat = 0
    private var fieldHeight: CGFloat = 0
//    private var modifiedIndexPaths: Set<IndexPath> = []
    
    fileprivate var lastZoomedWidth: CGFloat = 0
    
    fileprivate var topConstraint: NSLayoutConstraint?
    fileprivate var leadingConstraint: NSLayoutConstraint?
    
    // This gridViewBounds is an inverse zoom of the contentSize.  As content size of this scrollview scales down,
    // this gridViewBounds will appear to have enlarge to the underlying collectionview.
    fileprivate var gridViewBounds: CGRect {
        // This gridViewBounds is effectively 100px larger on all sides than the actual container view
        // to prevent clipping outside of safe regions.
        let newOffsetX = (self.contentOffset.x - 100) / self.zoomScale
        let newOffsetY = (self.contentOffset.y - 100) / self.zoomScale
        let newWidth = (self.bounds.width + 200) / self.zoomScale
        let newHeight = (self.bounds.height + 200) / self.zoomScale
        
        return CGRect(x: newOffsetX, y: newOffsetY, width: newWidth, height: newHeight)
    }
    
    lazy private var setUpOnce: Void = {
        self.delegate = self
        
        self.isScrollEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        let fieldGrid = FieldGridCollectionView(frame: self.frame, collectionViewLayout: FieldGridCollectionViewLayout())
        fieldGrid.backgroundColor = UIColor.clear
        fieldGrid.layer.borderWidth = Constants.fieldBorderWidth
        fieldGrid.layer.borderColor = UIColor.black.cgColor
        fieldGrid.isScrollEnabled = false
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
                        cellActionHandler: FieldGridCellActionListener,
                        completionHandler: FieldSetupCompletionHandler?) {
        
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        if rows == self.rowCount, columns == self.columnCount {
            // Dimension didn't change, so just reset it
            fieldGridCollection.dataSource = dataSource
            fieldGridCollection.cellActionHandler = cellActionHandler
            
            fieldGridCollection.gridViewBounds = self.gridViewBounds
            
            // Show and reload only what's been affected
            fieldGridCollection.isHidden = false
//            fieldGridCollection.reloadItems(at: Array(self.modifiedIndexPaths))
            fieldGridCollection.reloadData()
            
//            self.modifiedIndexPaths.removeAll()
            self.contentSize = CGSize(width: self.fieldWidth, height: self.fieldHeight)
            
            self.recenterFieldGrid()
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.zoomScale = 1.0
                    self.contentOffset.x = 0
                    self.contentOffset.y = 0
                }
                
                completionHandler?(self.fieldWidth, self.fieldHeight)
            }
            
            return
        }
        
        self.rowCount = rows
        self.columnCount = columns
//        self.modifiedIndexPaths.removeAll()
        
        fieldGridCollection.setupFieldGrid(rows: rows, columns: columns, dataSource: dataSource, cellActionHandler: cellActionHandler) { [weak self] (fieldWidth, fieldHeight) in
            guard let `self` = self else { return }
            self.fieldWidth = fieldWidth
            self.fieldHeight = fieldHeight
            
            self.contentSize = CGSize(width: fieldWidth, height: fieldHeight)
            
            self.calculateGridLayoutParams(width: fieldWidth, height: fieldHeight)
            
            fieldGridCollection.gridViewBounds = self.gridViewBounds
            
            // Show and reload
            fieldGridCollection.isHidden = false
            fieldGridCollection.reloadData()
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.zoomScale = 1.0
                    self.contentOffset.x = 0
                    self.contentOffset.y = 0
                }
                
                completionHandler?(fieldWidth, fieldHeight)
            }
        }
    }
    
    private func calculateScaleFactors() {
        let windowWidth = self.frame.width
        let windowHeight = self.frame.height
        
        // Figure out which dimension is wider than screen when normalized, that dimension would determine the mininum scale factor
        // to fit the entire field into the container
        let screenAspect = windowWidth / windowHeight
        let fieldAspect = self.fieldWidth / self.fieldHeight
        
        let newMinScale = (fieldAspect > screenAspect) ? windowWidth / self.fieldWidth : windowHeight / self.fieldHeight
        
        if self.minScaleFactor < newMinScale {
            self.zoomScale = newMinScale
        }
        
        self.minScaleFactor = newMinScale
        
        self.minimumZoomScale = self.minScaleFactor
        self.maximumZoomScale = Constants.defaultMaxScaleFactor
    }
    
    func showEntireField() {
        UIView.animate(withDuration: 0.3) {
            self.zoomScale = self.minScaleFactor
            self.fieldGridCollection?.gridViewBounds = self.gridViewBounds
            self.recenterFieldGrid()
        }
    }
    
    func updateCells(at indexPaths: [IndexPath]) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        // keep track of which cell has been affected
//        self.modifiedIndexPaths = self.modifiedIndexPaths.union(indexPaths)
        DispatchQueue.main.async {
            fieldGridCollection.reloadItems(at: indexPaths)
        }
    }
    
    func calculateGridLayoutParams(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.calculateScaleFactors()
        self.lastZoomedWidth = 0
        self.recenterFieldGrid(width: width, height: height)
    }
    
    fileprivate func recenterFieldGrid(width: CGFloat? = nil, height: CGFloat? = nil) {
        guard self.lastZoomedWidth != self.contentSize.width,
            let fieldGrid = self.fieldGridCollection else { return }
        
        let fieldWidth = width ?? self.contentSize.width
        let fieldHeight = height ?? self.contentSize.height

        let windowWidth = self.frame.width
        let windowHeight = self.frame.height
        
        self.lastZoomedWidth = fieldWidth

        if fieldWidth > windowWidth, fieldHeight > windowHeight {
            self.resetConstraintsToOrigin()
        } else {
            self.leadingConstraint?.isActive = false
            self.topConstraint?.isActive = false
            
            if fieldWidth < windowWidth {
                // lockOffsetX
                let xOffset = (windowWidth - fieldWidth) / 2
                
                let leadingConstraint = fieldGrid.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: xOffset)
                self.leadingConstraint = leadingConstraint
            } else {
                let leadingConstraint = fieldGrid.leadingAnchor.constraint(equalTo: self.leadingAnchor)
                self.leadingConstraint = leadingConstraint
            }
            
            if fieldHeight < windowHeight {
                // lockOffsetY
                let yOffset = (windowHeight - fieldHeight) / 2
                
                let topConstraint = fieldGrid.topAnchor.constraint(equalTo: self.topAnchor, constant: yOffset)
                self.topConstraint = topConstraint
            } else {
                let topConstraint = fieldGrid.topAnchor.constraint(equalTo: self.topAnchor)
                self.topConstraint = topConstraint
            }
            
            self.topConstraint?.isActive = true
            self.leadingConstraint?.isActive = true
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    private func resetConstraintsToOrigin() {
        guard let fieldGrid = self.fieldGridCollection else { return }
        
        self.leadingConstraint?.isActive = false
        self.topConstraint?.isActive = false
        
        let leadingConstraint = fieldGrid.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        self.leadingConstraint = leadingConstraint
        
        let topConstraint = fieldGrid.topAnchor.constraint(equalTo: self.topAnchor)
        self.topConstraint = topConstraint
        
        self.topConstraint?.isActive = true
        self.leadingConstraint?.isActive = true
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
}

extension FieldGridScrollView: UIScrollViewDelegate {
    // Zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.fieldGridCollection
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // The view rect has changed due to Zooming, so update the grid's view bounds
        self.fieldGridCollection?.gridViewBounds = self.gridViewBounds
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.recenterFieldGrid()
    }
    
    // Panning
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // The content has shifted due to Panning, so update the grid's view bounds
        self.fieldGridCollection?.gridViewBounds = self.gridViewBounds
    }
}

extension FieldGridScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

