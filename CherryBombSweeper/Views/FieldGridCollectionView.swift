//
//  FieldGridCollectionView.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/15/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class FieldGridCollectionView: UICollectionView {
    
    enum Constant {
        static let cellDimension = CGFloat(44)
        static let cellInset = CGFloat(1)
        static let gridCellIdentifier = "FieldGridCell"
        static let maxScaleFactor: CGFloat = 1.5
    }
    
    fileprivate var containerView: UIView?
    fileprivate var mineField: MineField?
    
    /// Pinch
    fileprivate var enableZooming: Bool = false
    fileprivate var isZoomed: Bool = false
    fileprivate var enablePanning: Bool = false
    fileprivate var minScaleFactor: CGFloat = 1
    
    /// Pan
    fileprivate var originalFieldCenter: CGPoint?
    
    fileprivate var cellTapHandler: CellTapHandler?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.delegate = self
        
        self.register(UINib(nibName: Constant.gridCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Constant.gridCellIdentifier)
    }
    
    func setupFieldGrid(with mineField: MineField, containerView: UIView,
                        dataSource: UICollectionViewDataSource,
                        cellTapHandler: @escaping CellTapHandler) {
        self.dataSource = dataSource
        self.mineField = mineField
        self.containerView = containerView
        self.cellTapHandler = cellTapHandler
        
        let screenWidth = containerView.bounds.width
        let screenHeight = containerView.bounds.height
        let rows = CGFloat(mineField.rows)
        let columns = CGFloat(mineField.columns)
        
        let fieldWidth = (columns * (Constant.cellDimension + Constant.cellInset)) - Constant.cellInset
        let fieldHeight = (rows * (Constant.cellDimension + Constant.cellInset)) - Constant.cellInset
        
        // Figure out which dimension is wider than screen when normalized, that dimension would determine the mininum scale factor
        // to fit the entire field into the container
        let screenAspect = screenWidth / screenHeight
        let fieldAspect = fieldWidth / fieldHeight
        // fieldAspect > screenAspect = field width is wider
        self.minScaleFactor = (fieldAspect > screenAspect)
            ? screenWidth / fieldWidth
            : screenHeight / fieldHeight
        
        // Setting field width and height via auto layout
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        self.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        // Check if zooming and panning should be enabled
        if fieldWidth > screenWidth || fieldHeight > screenHeight {
            self.enableZooming = true
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchHandler(sender:)))
            pinch.delegate = self
            self.addGestureRecognizer(pinch)
            
            self.enablePanning = true
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler(sender:)))
            pan.delegate = self
            self.addGestureRecognizer(pan)
        }
        
        // Now scale the entire field to fit onto screen
        self.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
        
        // Show and reload
        self.isHidden = false
        self.reloadData()
        
        DispatchQueue.main.async {
            // Capture the field center for zoom resetting
            self.originalFieldCenter = self.center
        }
    }
    
    func pinchHandler(sender: UIPinchGestureRecognizer) {
        guard self.enableZooming else { return }
        
        let currentScale = self.frame.size.width / self.bounds.size.width
        
        switch sender.state {
        case .began:
            let newScale = currentScale * sender.scale
            if newScale > self.minScaleFactor {
                self.isZoomed = true
                self.enablePanning = true
            }
        case .changed:
            let newScale = currentScale * sender.scale
            // Don't perform scaling if the new scaling factor exceeds the max scale factor
            guard let view = sender.view, newScale < Constant.maxScaleFactor else {
                return
            }
            
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
            view.transform = transform
            sender.scale = 1
        case .ended, .cancelled, .failed:
            guard currentScale <= self.minScaleFactor, let view = sender.view,
                let containerView = self.containerView else {
                return
            }
            
            // Zoom is now below minScaleFactor, so clamp it to minScaleFactor
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
            })
   
            self.isZoomed = false
            
            if let center = self.originalFieldCenter {
                self.center = center
            }
            
            if view.frame.width <= containerView.bounds.width,
                view.frame.height <= containerView.bounds.height {
                self.enablePanning = false
            }

            sender.scale = 1
        case .possible:
            break
        }
    }
    
    func panHandler(sender: UIPanGestureRecognizer) {
        guard self.enablePanning else { return }
        
        switch sender.state {
        case .began, .changed:
            let translation = sender.translation(in: self.containerView)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            
            sender.setTranslation(CGPoint.zero, in: self.containerView)
        case .ended, .cancelled, .failed:
            guard let view = sender.view, let containerView = self.containerView else { return }
            
            // Fetching some values in the main thread
            let viewLeftEdge = view.frame.minX
            let viewRightEdge = view.frame.maxX
            let containerLeftEdge = containerView.bounds.minX
            let containerRightEdge = containerView.bounds.maxX
            let isSmallWidth: Bool = view.frame.width <= containerView.bounds.width
            
            let viewTopEdge = view.frame.minY
            let viewBottomEdge = view.frame.maxY
            let containerTopEdge = containerView.bounds.minY
            let containerBottomEdge = containerView.bounds.maxY
            let isSmallHeight: Bool = view.frame.height <= containerView.bounds.height
            
            // Now do calculations in the background thread
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let `self` = self else { return }
                
                // Figure out clamping after pan completes
                var xDiff: CGFloat = 0
                if isSmallWidth {
                    if viewLeftEdge < containerLeftEdge {
                        xDiff = containerLeftEdge - viewLeftEdge // clamp leftedge
                    } else if viewRightEdge > containerRightEdge {
                        xDiff = containerRightEdge - viewRightEdge // clamp right edge
                    }
                } else if viewLeftEdge > containerLeftEdge {
                    xDiff = containerLeftEdge - viewLeftEdge // lamp left edge
                } else if viewRightEdge < containerRightEdge {
                    xDiff = containerRightEdge - viewRightEdge // clamp right edge
                }
                
                var yDiff: CGFloat = 0
                if isSmallHeight {
                    if viewTopEdge < containerTopEdge {
                        yDiff = containerTopEdge - viewTopEdge // clamp top edge
                    } else if viewBottomEdge > containerBottomEdge {
                        yDiff = containerBottomEdge - viewBottomEdge // clamp bottom edge
                    }
                } else if viewTopEdge > containerTopEdge {
                    yDiff = containerTopEdge - viewTopEdge // clamp top edge
                } else if viewBottomEdge < containerBottomEdge {
                    yDiff = containerBottomEdge - viewBottomEdge // clamp bottom edge
                }
                
                // Then finally execute animation on the main thread
                DispatchQueue.main.async {  [weak self, xDiff, yDiff] in
                    guard let `self` = self else { return }
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        view.center = CGPoint(x:view.center.x + xDiff,
                                              y:view.center.y + yDiff)
                        
                        sender.setTranslation(CGPoint.zero, in: self.containerView)
                    })
                }
            }
        case .possible:
            break
        }
    }
}

extension FieldGridCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath) {
        self.cellTapHandler?(didSelectItemAt.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.cellInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constant.cellInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: Constant.cellDimension, height: Constant.cellDimension);
    }
}

extension FieldGridCollectionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
