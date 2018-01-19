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
        
        let fieldGrid = FieldGridCollectionView(frame: self.frame, collectionViewLayout: FieldGridCollectionViewLayout())
        self.fieldGridCollection = fieldGrid
        fieldGrid.isHidden = true
        self.addSubview(fieldGrid)
        
        let _ = setupRecognizers
    }
    
    func setupFieldGrid(with mineField: MineField,
                        dataSource: UICollectionViewDataSource,
                        cellTapHandler: @escaping CellTapHandler) {
        guard let fieldGridCollection = self.fieldGridCollection else { return }
        
        fieldGridCollection.setupFieldGrid(with: mineField, container: self, dataSource: dataSource, cellTapHandler: cellTapHandler)
        
        let windowWidth = self.frame.width
        let windowHeight = self.frame.height
        
        let fieldWidth = fieldGridCollection.frame.width
        let fieldHeight = fieldGridCollection.frame.height
        
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
        
        // Now scale the entire field to fit onto screen
        fieldGridCollection.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
        
        fieldGridCollection.reloadData()
        
        DispatchQueue.main.async {
            // Capture the field center for zoom resetting
            let _ = self.captureFieldCenter
        }
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
            
            fieldGridCollection.transform = transform
            sender.scale = 1
        case .ended, .cancelled, .failed:
            guard currentScale <= self.minScaleFactor, let fieldGridCollection = self.fieldGridCollection else {
                    return
            }
            
            // Zoom is now below minScaleFactor, so clamp it to minScaleFactor
            UIView.animate(withDuration: 0.3, animations: {
                fieldGridCollection.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
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

