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
    }
    
    fileprivate var fieldGridCollection: FieldGridCollectionView?
    
    /// Pinch
    fileprivate var enableZooming: Bool = true
    fileprivate var isZoomed: Bool = false
    fileprivate var minScaleFactor: CGFloat = 1
    fileprivate var fieldOrigin: CGPoint?
    
    fileprivate var cellTapHandler: CellTapHandler?
    
    lazy private var setupGridCollectionView: Void = {
        let fieldGrid = FieldGridCollectionView(frame: self.frame, collectionViewLayout: FieldGridCollectionViewLayout())
        self.fieldGridCollection = fieldGrid
        fieldGrid.isHidden = true
        
        self.addSubview(fieldGrid)
    }()
    
    lazy private var setupFieldConstraint: Void = {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        fieldGridCollection.translatesAutoresizingMaskIntoConstraints = false
        fieldGridCollection.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        fieldGridCollection.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }()
    
    lazy private var captureFieldOrigin: Void = {
        self.fieldOrigin = self.fieldGridCollection?.frame.origin
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let _ = setupGridCollectionView
        
        self.delegate = self
        
        self.isScrollEnabled = true
    }
    
    func setupFieldGrid(with mineField: MineField,
                        dataSource: UICollectionViewDataSource,
                        cellTapHandler: @escaping CellTapHandler) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        fieldGridCollection.setupFieldGrid(with: mineField, dataSource: dataSource, cellTapHandler: cellTapHandler) { [weak self] (fieldWidth, fieldHeight) in
            guard let `self` = self else { return }
            
            let windowWidth = self.frame.width
            let windowHeight = self.frame.height
    
            // Figure out which dimension is wider than screen when normalized, that dimension would determine the mininum scale factor
            // to fit the entire field into the container
            let screenAspect = windowWidth / windowHeight
            let fieldAspect = fieldWidth / fieldHeight
            // fieldAspect > screenAspect = field width is wider
            self.minScaleFactor = (fieldAspect > screenAspect)
                ? windowWidth / fieldWidth
                : windowHeight / fieldHeight
            
            // Check if zooming and panning should be enabled
            if fieldWidth > windowWidth || fieldHeight > windowHeight {
                self.enableZooming = true
            }
            
            self.minimumZoomScale = self.minScaleFactor
            self.maximumZoomScale = Constant.maxScaleFactor
            self.contentSize = CGSize(width: fieldWidth, height: fieldHeight)
            
            let _ = self.setupFieldConstraint
            
            if let fieldOrigin = self.fieldOrigin {
                self.setContentOffset(fieldOrigin, animated: true)
            }
            
            // Show and reload
            fieldGridCollection.isHidden = false
            fieldGridCollection.reloadData()
            
            DispatchQueue.main.async {
                let _ = self.captureFieldOrigin
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

