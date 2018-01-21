//
//  FieldGridScrollView.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/19/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class FieldGridScrollView: UIScrollView {
    
    enum Constant {
        static let maxScaleFactor: CGFloat = 3
        static let borderWidth: CGFloat = 2
    }
    
    fileprivate var fieldGridCollection: FieldGridCollectionView?
    
    /// Pinch
    fileprivate var enableZooming: Bool = true
    fileprivate var isZoomed: Bool = false
    fileprivate var minScaleFactor: CGFloat = 1
    
//    private var maxContentOffset: CGFloat = 0
    
    fileprivate var cellTapHandler: CellTapHandler?
    
    lazy private var setUpOnce: Void = {
        self.delegate = self
        
        self.isScrollEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        let fieldGrid = FieldGridCollectionView(frame: self.frame, collectionViewLayout: FieldGridCollectionViewLayout())
        fieldGrid.layer.borderWidth = Constant.borderWidth
        fieldGrid.layer.borderColor = UIColor.black.cgColor
        self.fieldGridCollection = fieldGrid
        fieldGrid.isHidden = true
        
        self.addSubview(fieldGrid)
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let _ = setUpOnce
    }
    
    func setupFieldGrid(with mineField: MineField,
                        dataSource: UICollectionViewDataSource,
                        cellTapHandler: @escaping CellTapHandler,
                        completionHandler: FieldSetupCompletionHandler?) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        fieldGridCollection.setupFieldGrid(with: mineField, dataSource: dataSource, cellTapHandler: cellTapHandler) { [weak self] (fieldWidth, fieldHeight) in
            guard let `self` = self else { return }
            
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
            
            // Check if zooming and panning should be enabled
            if fieldWidth > windowWidth || fieldHeight > windowHeight {
                self.enableZooming = true
            }
            
            self.minimumZoomScale = self.minScaleFactor
            self.maximumZoomScale = Constant.maxScaleFactor
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

