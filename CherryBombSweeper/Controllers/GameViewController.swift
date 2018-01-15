//
//  GameViewController.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    enum Constants {
        static let cellDimension = CGFloat(40)
        static let cellInset = CGFloat(1)
        static let gridCellIdentifier = "FieldGridCell"
    }
    
    @IBOutlet private weak var fieldGridView: UICollectionView!
    @IBOutlet private weak var fieldContainer: UIView!
    
    fileprivate var gameOptions: GameOptions = GameServices.shared.gameOptions
    fileprivate var game: Game = Game()
    
    fileprivate var cellDimension: CGFloat = Constants.cellDimension
    
    /// Pinch
    fileprivate var enableZooming: Bool = false
    fileprivate var isZoomed: Bool = false
    fileprivate var enablePanning: Bool = false
    fileprivate var minScaleFactor: CGFloat = 1
    fileprivate var maxScaleFactor: CGFloat = 1
    
    /// Pan
    fileprivate var originalFieldCenter: CGPoint?
    
    private lazy var initGame: Void = {
        GameServices.shared.generateNewGame { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            self.game = newGame
            
            self.setupFieldGridView()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Game View Controller"
        self.fieldGridView.dataSource = self
        self.fieldGridView.delegate = self
        
        self.fieldGridView.register(UINib(nibName: Constants.gridCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Constants.gridCellIdentifier)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let _ = self.initGame
        
        if self.enableZooming {
                let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
                pinch.delegate = self
                self.fieldGridView.addGestureRecognizer(pinch)
            
                let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
                pan.delegate = self
                self.fieldGridView.addGestureRecognizer(pan)
                self.originalFieldCenter = self.fieldGridView.center
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupFieldGridView() {
        DispatchQueue.main.async {
            let screenWidth = self.view.frame.width
            
            let rowGuttersWidth = CGFloat(self.game.mineField.rows - 1) * Constants.cellInset
            let columnGuttersWidth = CGFloat(self.game.mineField.columns - 1) * Constants.cellInset
            let totalCellWidth = screenWidth - columnGuttersWidth
            self.cellDimension = totalCellWidth / CGFloat(self.game.mineField.columns)
            
            self.maxScaleFactor = (Constants.cellDimension / self.cellDimension) + CGFloat(0.5)
            
            let totalFieldWidth = (self.cellDimension * CGFloat(self.game.mineField.columns)) + columnGuttersWidth
            let totalFieldHeight = (self.cellDimension * CGFloat(self.game.mineField.rows)) + rowGuttersWidth
            
            if self.cellDimension < Constants.cellDimension ||
                totalFieldWidth > self.fieldContainer.bounds.width ||
                totalFieldHeight > self.fieldContainer.bounds.height {
                self.enableZooming = true
            }

            self.fieldGridView.translatesAutoresizingMaskIntoConstraints = false
            self.fieldGridView.widthAnchor.constraint(equalToConstant: totalFieldWidth).isActive = true
            self.fieldGridView.heightAnchor.constraint(equalToConstant: totalFieldHeight).isActive = true
            self.fieldGridView.centerXAnchor.constraint(equalTo: self.fieldContainer.centerXAnchor).isActive = true
            self.fieldGridView.centerYAnchor.constraint(equalTo: self.fieldContainer.centerYAnchor).isActive = true
            
            // Dispatching main async here forces this to be performed AFTER all of the setup above
            DispatchQueue.main.async {
                self.fieldGridView.reloadData()
            }
        }
    }
    
    func pinch(sender: UIPinchGestureRecognizer) {
        guard self.enableZooming else { return }
        
        let currentScale = self.fieldGridView.frame.size.width / self.fieldGridView.bounds.size.width
        
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
            if currentScale <= 1 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.fieldGridView.transform = CGAffineTransform.identity
                    if let center = self.originalFieldCenter {
                        self.fieldGridView.center = center
                    }
                    self.isZoomed = false
                    self.enablePanning = false
                })
            }
//            else if currentScale > self.maxScaleFactor {
//                guard let view = sender.view else { return }
//                let newScale = self.maxScaleFactor/currentScale
//
//                let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
//                                          y: sender.location(in: view).y - view.bounds.midY)
//
//                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
//                    .scaledBy(x: newScale, y: newScale)
//                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
//
////                let transform = CGAffineTransform(scaleX: self.maxScaleFactor, y: self.maxScaleFactor)
//                UIView.animate(withDuration: 0.3, animations: {
//                    view.transform = transform
//                })
//            }
            sender.scale = 1
        case .possible:
            break
        }
    }
    
    func pan(sender: UIPanGestureRecognizer) {
        guard self.enablePanning else { return }
        
        switch sender.state {
        case .began, .changed:
            let translation = sender.translation(in: self.fieldContainer)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            
            sender.setTranslation(CGPoint.zero, in: self.fieldContainer)
        case .ended, .cancelled, .failed:
            // Figure out clamping after pan completes
            if let view = sender.view {
                
                var xDiff: CGFloat = 0
                let viewLeftEdge = view.frame.minX
                let viewRightEdge = view.frame.maxX
                let containerLeftEdge = self.fieldContainer.bounds.minX
                let containerRightEdge = self.fieldContainer.bounds.maxX
                
                if view.frame.width <= self.fieldContainer.bounds.width {
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
                let containerTopEdge = self.fieldContainer.bounds.minY
                let containerBottomEdge = self.fieldContainer.bounds.maxY
                
                if view.frame.height <= self.fieldContainer.bounds.height {
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
                    
                    sender.setTranslation(CGPoint.zero, in: self.fieldContainer)
                })
            }
            break
        case .possible:
            break
        }
    }
}

extension GameViewController: UICollectionViewDelegateFlowLayout {
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

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.mineField.cellCoordMap.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.gridCellIdentifier, for: indexPath) as? FieldGridCell {
            if let cellCoord = self.game.mineField.cellCoordMap[indexPath.row] {
                let cell = self.game.mineField.fieldGrid[cellCoord.row][cellCoord.column]
                
                if cell.hasBomb {
                    cellView.cellIcon.isHidden = false
                }
            }
            
            return cellView
        }
        
        return FieldGridCell()
    }
}

extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
