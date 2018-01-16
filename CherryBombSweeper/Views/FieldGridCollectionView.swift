//
//  FieldGridCollectionView.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/15/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class FieldGridCollectionView: UICollectionView {
    
    enum Constants {
        static let optimalCellDimension = CGFloat(40)
        static let cellInset = CGFloat(1)
        static let gridCellIdentifier = "FieldGridCell"
    }
    
    fileprivate var containerView: UIView = UIView()
    fileprivate var mineField: MineField = MineField()
    fileprivate var cellDimension: CGFloat = Constants.optimalCellDimension
    var scaledFactor: CGFloat = 1
    
    /// Pinch
    fileprivate var enableZooming: Bool = false
    fileprivate var isZoomed: Bool = false
    fileprivate var enablePanning: Bool = false
    fileprivate var minScaleFactor: CGFloat = 1
    fileprivate var maxScaleFactor: CGFloat = 1
    
    /// Pan
    fileprivate var originalFieldCenter: CGPoint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.delegate = self
        
        self.register(UINib(nibName: Constants.gridCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Constants.gridCellIdentifier)
    }
    
    func setupFieldGrid(with mineField: MineField, containerView: UIView, dataSource: UICollectionViewDataSource) {
        self.dataSource = dataSource
        
        self.mineField = mineField
        self.containerView = containerView
        
        let screenWidth = containerView.bounds.width
        let screenHeight = containerView.bounds.height
        let floatRows = CGFloat(self.mineField.rows)
        let floatColumns = CGFloat(self.mineField.columns)
        
        let rowGuttersWidth = CGFloat(self.mineField.rows - 1) * Constants.cellInset
        let columnGuttersWidth = CGFloat(self.mineField.columns - 1) * Constants.cellInset
        
        let totalCellWidth = screenWidth - columnGuttersWidth
        self.cellDimension = totalCellWidth / floatColumns
        
        let fieldWidth = (self.cellDimension * floatColumns) + columnGuttersWidth
        let fieldHeight = (self.cellDimension * floatRows) + rowGuttersWidth
        
        self.scaledFactor = self.cellDimension / Constants.optimalCellDimension
        // Figure out which dimension is wider than screen when normalized
        let screenAspect = screenWidth / screenHeight
        let fieldAspect = fieldWidth / fieldHeight
        // fieldAspect > screenAspect = field width is wider
        self.minScaleFactor = (fieldAspect > screenAspect) ? screenWidth/fieldWidth : screenHeight/fieldHeight
        self.maxScaleFactor = Constants.optimalCellDimension / self.cellDimension + CGFloat(0.5)
        
        // Setting field width and height via auto layout
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        self.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        self.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        
        // Check if zooming and panning should be enabled
        if self.cellDimension < Constants.optimalCellDimension ||
            fieldWidth > self.containerView.bounds.width ||
            fieldHeight > self.containerView.bounds.height {
            self.enableZooming = true
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchHandler(sender:)))
            pinch.delegate = self
            self.addGestureRecognizer(pinch)
            
            self.enablePanning = true
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler(sender:)))
            pan.delegate = self
            self.addGestureRecognizer(pan)
        }
        
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
            if newScale > 1 {
                self.isZoomed = true
                self.enablePanning = true
            }
        case .changed:
            let newScale = currentScale * sender.scale
            // Don't perform scaling if the new scaling factor exceeds the max scale factor
            guard let view = sender.view, newScale < self.maxScaleFactor else {
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
            guard let view = sender.view else {
                return
            }
            
            if currentScale <= self.minScaleFactor {
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
                })
                
                if let center = self.originalFieldCenter {
                    self.center = center
                }
                
                if view.frame.width <= self.containerView.bounds.width,
                    view.frame.height <= self.containerView.bounds.height {
                    self.enablePanning = false
                }
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
            // Figure out clamping after pan completes
            if let view = sender.view {
                
                var xDiff: CGFloat = 0
                let viewLeftEdge = view.frame.minX
                let viewRightEdge = view.frame.maxX
                let containerLeftEdge = self.containerView.bounds.minX
                let containerRightEdge = self.containerView.bounds.maxX
                
                if view.frame.width <= self.containerView.bounds.width {
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
                let viewTopEdge = view.frame.minY
                let viewBottomEdge = view.frame.maxY
                let containerTopEdge = self.containerView.bounds.minY
                let containerBottomEdge = self.containerView.bounds.maxY
                
                if view.frame.height <= self.containerView.bounds.height {
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
                
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = CGPoint(x:view.center.x + xDiff,
                                          y:view.center.y + yDiff)
                    
                    sender.setTranslation(CGPoint.zero, in: self.containerView)
                })
            }
            break
        case .possible:
            break
        }
    }
}

extension FieldGridCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.cellInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.cellInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.cellDimension, height: self.cellDimension);
    }
}

extension FieldGridCollectionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
