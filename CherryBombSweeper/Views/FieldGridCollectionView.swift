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
        static let cellDimension = CGFloat(41)
        static let cellInset = CGFloat(1)
        static let gridCellIdentifier = "FieldGridCell"
//        static let maxScaleFactor: CGFloat = 3
    }
    
    fileprivate var mineField: MineField?
    
    /// Pinch
//    fileprivate var pinchGesture: UIPinchGestureRecognizer?
//    fileprivate var enableZooming: Bool = true
//    fileprivate var isZoomed: Bool = false
//    fileprivate var enablePanning: Bool = false
    fileprivate var minScaleFactor: CGFloat = 1
    fileprivate var cellDimension: CGFloat = Constant.cellDimension
//    fileprivate var scaleFactor: CGFloat = 1
    
    /// Pan
//    fileprivate var originalFieldCenter: CGPoint?
    
    fileprivate var cellTapHandler: CellTapHandler?
    
//    lazy private var setupRecognizers: Void = {
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchHandler(sender:)))
//        pinch.delegate = self
//        self.addGestureRecognizer(pinch)
//
////        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler(sender:)))
////        pan.delegate = self
////        self.addGestureRecognizer(pan)
//    }()
    
//    lazy private var captureFieldCenter: Void = {
//        self.originalFieldCenter = self.center
//    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.minimumZoomScale = 1
//        self.maximumZoomScale = Constant.maxScaleFactor
        
        self.delegate = self
        
//        let _ = setupRecognizers
        
        self.register(UINib(nibName: Constant.gridCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Constant.gridCellIdentifier)
    }
    
    func setupFieldGrid(with mineField: MineField,
                        dataSource: UICollectionViewDataSource,
                        cellTapHandler: @escaping CellTapHandler) {
        self.dataSource = dataSource
        self.mineField = mineField
        self.cellTapHandler = cellTapHandler
        
        if let layout = self.collectionViewLayout as? FieldGridCollectionViewLayout {
            layout.delegate = self
        }
        
//        let screenWidth = self.frame.width
//        let screenHeight = self.frame.height
//        let rows = CGFloat(mineField.rows)
//        let columns = CGFloat(mineField.columns)

//        let fieldWidth = (columns * (self.cellDimension + Constant.cellInset)) - Constant.cellInset
//        let fieldHeight = (rows * (self.cellDimension + Constant.cellInset)) - Constant.cellInset
//
//        // Figure out which dimension is wider than screen when normalized, that dimension would determine the mininum scale factor
//        // to fit the entire field into the container
//        let screenAspect = screenWidth / screenHeight
//        let fieldAspect = fieldWidth / fieldHeight
//         fieldAspect > screenAspect = field width is wider
//        self.cellDimension = (fieldAspect > screenAspect)
//            ? (screenWidth - (8 * Constant.cellInset)) / 9
//            : (screenHeight - (8 * Constant.cellInset)) / 9
        
        // Check if zooming and panning should be enabled
//        if fieldWidth > screenWidth || fieldHeight > screenHeight {
//            self.enableZooming = true
//        }
        
        // Now scale the entire field to fit onto screen
//        self.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
//        self.cellDimension = self.cellDimension * self.minScaleFactor
        
        // Show and reload
        self.isHidden = false
        self.reloadData()
        
//        DispatchQueue.main.async {
////             Capture the field center for zoom resetting
//            let _ = self.captureFieldCenter
//        }
    }
    
//    @objc private func pinchHandler(sender: UIPinchGestureRecognizer) {
//        guard self.enableZooming else { return }
//
////        let currentScale = self.frame.size.width / self.bounds.size.width
////        var currentScale: CGFloat = self.scaleFactor
//
//        switch sender.state {
//        case .began:
////            currentScale = self.scaleFactor
////            let newScale = currentScale * sender.scale
////            if newScale > self.minScaleFactor {
////                self.isZoomed = true
////            }
//            break
//        case .changed:
//            guard let layout = self.collectionViewLayout as? FieldGridCollectionViewLayout else {
//                return
//            }
//
//            let newScale = self.scaleFactor * sender.scale
//            // Don't perform scaling if the new scaling factor exceeds the max scale factor
//            if sender.scale < 1, newScale < self.minScaleFactor {
//                return
//            } else if sender.scale > 1, newScale > Constant.maxScaleFactor {
//                return
//            }
//
//            self.scaleFactor = newScale
//            print(self.scaleFactor)
//            layout.invalidateLayout()
//
////            sender.scale = newScale
////            view.invalidateIntrinsicContentSize()
////            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
////                                      y: sender.location(in: view).y - view.bounds.midY)
////
////            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
////                .scaledBy(x: sender.scale, y: sender.scale)
////                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
////
////            view.transform = transform
//        case .ended, .cancelled, .failed:
////            guard currentScale <= self.minScaleFactor else {
////                    return
////            }
////
////            // Zoom is now below minScaleFactor, so clamp it to minScaleFactor
////            UIView.animate(withDuration: 0.3, animations: {
////                self.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
////            })
////
////            self.isZoomed = false
////
////            if let center = self.originalFieldCenter {
////                self.center = center
////            }
//
////            sender.scale = 1
//            break
//        case .possible:
//            break
//        }
//    }
    
//    @objc private func pinchHandler(sender: UIPinchGestureRecognizer) {
//        guard self.enableZooming, let layout = self.collectionViewLayout as? FieldGridCollectionViewLayout else { return }
//
//        let currentScale = (self.cellDimension / Constant.cellDimension)
//
//        switch sender.state {
//        case .began:
//            break
////            let newScale = currentScale * sender.scale
////            if newScale > self.minScaleFactor {
////                self.isZoomed = true
////                self.enablePanning = true
////            }
//        case .changed:
//            // Don't perform scaling if the new scaling factor exceeds the max scale factor
//
////            let newScale = self.currentScaleFactor * sender.scale
////            if newScale > self.minScaleFactor, newScale <= Constant.maxScaleFactor {
////                self.currentScaleFactor = newScale
//            guard sender.scale > self.minScaleFactor, sender.scale < Constant.maxScaleFactor else {
//                return
//            }
//
//            self.cellDimension = self.cellDimension * sender.scale
//
//            layout.invalidateLayout()
//            }
            
//            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
//                                      y: sender.location(in: view).y - view.bounds.midY)
//
//            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
//                .scaledBy(x: sender.scale, y: sender.scale)
//                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
//
//            view.transform = transform
//            sender.scale = 1
//        case .ended, .cancelled, .failed:
//
//            var reset: Bool = false
//            if currentScale < self.minScaleFactor {
//                self.currentScaleFactor = self.minScaleFactor
//                self.cellDimension = Constant.cellDimension * self.currentScaleFactor
//
//                reset = true
//            } else if currentScale > Constant.maxScaleFactor {
//                self.currentScaleFactor = Constant.maxScaleFactor
//                self.cellDimension = Constant.cellDimension * Constant.maxScaleFactor
//
//                reset = true
//            }
//
//            if reset {
////                UIView.animate(withDuration: 0.3, animations: {
//                    layout.invalidateLayout()
////                    self.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
////                })
//            }
//            guard currentScale <= self.minScaleFactor, let view = sender.view,
//                let containerView = self.superview else {
//                return
//            }
//
//            // Zoom is now below minScaleFactor, so clamp it to minScaleFactor
//            UIView.animate(withDuration: 0.3, animations: {
//                self.transform = CGAffineTransform(scaleX: self.minScaleFactor, y: self.minScaleFactor)
//            })
//
//            self.isZoomed = false
//
////            if let center = self.originalFieldCenter {
////                self.center = center
////            }
//
//            if view.frame.width <= containerView.bounds.width,
//                view.frame.height <= containerView.bounds.height {
//                self.enablePanning = false
//            }

//            sender.scale = 1
//            break
//        case .possible:
//            break
//        }
//    }
}

extension FieldGridCollectionView: FieldGridLayoutDelegate {    
    func collectionView(rowCountForFieldGrid collectionView: UICollectionView) -> Int {
        return self.mineField?.rows ?? 0
    }
    
    func collectionView(columnCountForFieldGrid collectionView: UICollectionView) -> Int {
        return self.mineField?.columns ?? 0
    }
    
    func collectionView(cellDimensionForFieldGrid collectionView: UICollectionView) -> CGFloat {
        return self.cellDimension // * self.scaleFactor
    }
    
    func collectionView(cellSpacingForFieldGrid collectionView: UICollectionView) -> CGFloat {
        return Constant.cellInset
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
        return CGSize(width: self.cellDimension, height: self.cellDimension);
    }
}

extension FieldGridCollectionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
