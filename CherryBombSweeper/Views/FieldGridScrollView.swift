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
    fileprivate var originalFieldCenter: CGPoint?
    
    fileprivate var cellTapHandler: CellTapHandler?
    
    lazy private var setupGridCollectionView: Void = {
        let fieldGrid = FieldGridCollectionView(frame: self.frame, collectionViewLayout: FieldGridCollectionViewLayout())
        self.fieldGridCollection = fieldGrid
        fieldGrid.isHidden = true
        
        self.addSubview(fieldGrid)
    }()
    
    lazy private var setupRecognizers: Void = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchHandler(sender:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
    }()
    
    lazy private var captureFieldCenter: Void = {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        self.originalFieldCenter = fieldGridCollection.center
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let _ = setupGridCollectionView
        
        let _ = setupRecognizers
        
        self.isScrollEnabled = true
        
//        if !self.bounds.size.equalTo(self.intrinsicContentSize) {
//            self.invalidateIntrinsicContentSize()
//        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
//            let intrinsicContentSize = self.contentSize
            
            return self.fieldGridCollection?.frame.size ?? self.contentSize
        }
    }
    
    func setupFieldGrid(with mineField: MineField,
                        dataSource: UICollectionViewDataSource,
                        cellTapHandler: @escaping CellTapHandler) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        fieldGridCollection.setupFieldGrid(with: mineField, dataSource: dataSource, cellTapHandler: cellTapHandler) { [weak self] (fieldWidth, fieldHeight) in
            guard let `self` = self else { return }
            
            let windowWidth = self.frame.width
            let windowHeight = self.frame.height
    
            self.contentSize.width = fieldWidth
            self.contentSize.height = fieldHeight
            
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
            
            // Setting field width and height via auto layout
            fieldGridCollection.translatesAutoresizingMaskIntoConstraints = false
            fieldGridCollection.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
            fieldGridCollection.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
            fieldGridCollection.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            fieldGridCollection.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            fieldGridCollection.isScrollEnabled = false
            
            // Now scale the entire field to fit onto screen
//            self.scaleContent(self.minScaleFactor)
//            self.transformContent(with: CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor))
//            self.contentSize.width = self.contentSize.width * self.minScaleFactor
//            self.contentSize.height = self.contentSize.height * self.minScaleFactor
//            self.contentScaleFactor = self.minScaleFactor
            
            // Show and reload
            fieldGridCollection.isHidden = false
            fieldGridCollection.reloadData()
            
            DispatchQueue.main.async {
                // Capture the field center for zoom resetting
                let _ = self.captureFieldCenter
            }
        }
    }
    
    private func transformContent(with transform: CGAffineTransform) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        fieldGridCollection.transform = transform
        self.invalidateIntrinsicContentSize()
    }
    
    func updateCells(at indexPaths: [IndexPath]) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        fieldGridCollection.reloadItems(at: indexPaths)
    }
    
    @objc private func pinchHandler(sender: UIPinchGestureRecognizer) {
        guard self.enableZooming else { return }
        
        let currentScale = self.frame.size.width / self.bounds.size.width
        
        switch sender.state {
        case .began:
            let newScale = currentScale * sender.scale
            if newScale > self.minScaleFactor {
                self.isZoomed = true
            }
        case .changed:
            let newScale = currentScale * sender.scale
            // Don't perform scaling if the new scaling factor exceeds the max scale factor
            guard let view = sender.view, let fieldGridCollection = self.fieldGridCollection, newScale < Constant.maxScaleFactor else {
                return
            }
            
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            
            let transform = fieldGridCollection.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
//            fieldGridCollection.transform = transform
            self.transformContent(with: transform)
//            self.contentSize.width = self.contentSize.width * sender.scale
//            self.contentSize.height = self.contentSize.height * sender.scale
//            self.contentScaleFactor = sender.scale
            sender.scale = 1
        case .ended, .cancelled, .failed:
            guard currentScale <= self.minScaleFactor, let fieldGridCollection = self.fieldGridCollection else {
                    return
            }
            
            // Zoom is now below minScaleFactor, so clamp it to minScaleFactor
            UIView.animate(withDuration: 0.3, animations: {
//                fieldGridCollection.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
                self.transformContent(with: CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor))
//                self.contentSize.width = self.contentSize.width * self.minScaleFactor
//                self.contentSize.height = self.contentSize.height * self.minScaleFactor
//                self.contentScaleFactor = self.minScaleFactor
            })
            
            self.isZoomed = false
            
            if let center = self.originalFieldCenter {
                fieldGridCollection.center = center
            }
            
            sender.scale = 1
        case .possible:
            break
        }
    }
}

extension FieldGridScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

