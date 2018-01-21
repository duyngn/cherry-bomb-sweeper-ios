//
//  GameViewController.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

enum UserAction {
    case tap
    case flag
}

typealias CellTapHandler = (_ cellIndex: Int) -> Void

class GameViewController: UIViewController {
    
    // Controls
    @IBOutlet private weak var controlsContainer: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var mineCountLabel: UILabel!
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet private weak var actionModeButton: UIButton!
    
//    @IBOutlet private weak var loadingSpinner: UIActivityIndicatorView!
    
    // Grid
    @IBOutlet fileprivate weak var minefieldView: FieldGridScrollView!

    fileprivate var gameOptions: GameOptions = GameGeneratorService.shared.gameOptions
    fileprivate var game: Game?
    fileprivate var isFieldInit: Bool = true
    
    private var currentUserAction: UserAction = .tap
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bkgPattern = GameGeneralService.shared.darkGrassImage {
            self.view.backgroundColor = UIColor.init(patternImage: bkgPattern)
        }
        
//        self.loadingSpinner.transform = CGAffineTransform(scaleX: Constant.loadingScale, y: Constant.loadingScale)
    }
    
    lazy private var initGame: Void = {
        GameProcessingService.shared.registerListener(self)
        self.startNewGame()
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let _ = initGame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupFieldGridView() {
        DispatchQueue.main.async {
            let actionableState: Set<GameState> = Set([.loaded, .new, .inProgress])
            
            self.minefieldView.setupFieldGrid(rows: self.gameOptions.rowCount,
                                              columns: self.gameOptions.columnCount,
                                              dataSource: self,
                                              cellTapHandler: { [weak self] (cellIndex) in
                                                
                guard let `self` = self, let game = self.game else { return }
                                                
                if actionableState.contains(game.state) {
                    self.gameStarted()
                    
                    GameProcessingService.shared.resolveUserAction(at: cellIndex, in: game, with: self.currentUserAction)
                }
            }) { (_, _) in
                // no-op
            }
        }
    }
    
    private func startNewGame() {
        self.gameOptions = GameGeneratorService.shared.gameOptions
        
        self.isFieldInit = true
        self.game = nil
        self.setupFieldGridView()
        
        self.resetControlStates()
        self.mineCountLabel.text = String(describing: self.gameOptions.minesCount)
        
        GameGeneratorService.shared.generateNewGame { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            newGame.state = .loaded
            
            self.game = newGame
            
            self.finishLoading()
        }
    }
    
    private func resetControlStates() {
        self.updateActionModeButton(to: .tap)
        
        if let bombImage = GameGeneralService.shared.bombImage {
            self.newGameButton.setImage(bombImage, for: UIControlState.normal)
        }
        
        self.newGameButton.transform = CGAffineTransform.identity
    }
    
    private func gameStarted() {
        guard let game = self.game, game.state != .inProgress else { return }
        
        self.game?.state = .inProgress
    }
    
    fileprivate func gameOver() {
        DispatchQueue.main.async {
            self.game?.state = .lost
            
            if let boomImage = GameGeneralService.shared.boomImage {
                self.newGameButton.setImage(boomImage, for: UIControlState.normal)
                self.newGameButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
            
            // Preload the next game
            GameGeneratorService.shared.preloadGame()
        }
    }
    
    fileprivate func gameCompleted() {
        DispatchQueue.main.async {
            self.game?.state = .win
            
//            self.mineCountLabel.setTitle("WINNER", for: UIControlState.normal)
            
            // Preload the next game
            GameGeneratorService.shared.preloadGame()
        }
    }
    
//    private func startLoading() {
//        self.loadingSpinner.startAnimating()
//        self.loadingSpinner.isHidden = false
//
//        self.minefieldView.isHidden = true
//    }
    
    private func finishLoading() {
        self.isFieldInit = false
        
//        DispatchQueue.main.async {
//            self.minefieldView.alpha = 0
//            self.minefieldView.isHidden = false
//
//            self.loadingSpinner.alpha = 1
//
//            UIView.animate(withDuration: 0.3, animations: {
//                self.minefieldView.alpha = 1
//                self.loadingSpinner.alpha = 0
//            }) { (_) in
//                self.loadingSpinner.isHidden = true
//                self.loadingSpinner.stopAnimating()
//            }
//        }
    }
    
    @IBAction func onOptionsPressed(_ sender: UIButton) {
        let optionsController = OptionsViewController(nibName: "OptionsViewController", bundle: nil)
        optionsController.exitHandler = { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            if newGame {
                self.startNewGame()
            }
        }
        
        self.present(optionsController, animated: true)
    }
    
    @IBAction func onActionModePressed(_ sender: UIButton) {
        self.updateActionModeButton(to: (self.currentUserAction == .tap) ? .flag : .tap)
    }
    
    @IBAction func onNewGamePressed(_ sender: UIButton) {
        self.startNewGame()
    }
    
    private func updateActionModeButton(to action: UserAction) {
        DispatchQueue.main.async {
            self.currentUserAction = action
            
            switch self.currentUserAction {
            case .flag:
                if let flagImage = GameGeneralService.shared.flagImage {
                    self.actionModeButton.setImage(flagImage, for: UIControlState.normal)
                }
            case .tap:
                if let shovelImage = GameGeneralService.shared.shovelImage {
                    self.actionModeButton.setImage(shovelImage, for: UIControlState.normal)
                }
            }
        }
    }
    
    fileprivate func updateRemainingMinesCountLabel() {
        if let minesCount = self.game?.minesRemaining {
            DispatchQueue.main.async {
                self.mineCountLabel.text = String(describing: minesCount)
            }
        }
    }
}

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.game?.mineField.cellIndexToCoordMap.count ?? self.gameOptions.rowCount * self.gameOptions.columnCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: FieldGridCollectionView.Constant.gridCellIdentifier, for: indexPath) as? FieldGridCell {
            
            if self.isFieldInit {
                cellView.reinitCell(at: indexPath.row, fieldRows: self.gameOptions.rowCount)
            } else if let game = self.game, let cell = game.mineField.getCell(at: indexPath.row) {
                cellView.setupCellView(with: cell)
            }
            
            return cellView
        }
        
        let cellView = FieldGridCell()
        cellView.reinitCell(at: indexPath.row, fieldRows: self.gameOptions.rowCount)
        return cellView
    }
}

extension GameViewController: GameStatusListener {
    func onCellReveal(_ revealedCells: Set<Int>) {
        let revealedIndexPaths = revealedCells.map { return IndexPath(row: $0, section: 0) }

        DispatchQueue.main.async {
            self.minefieldView.updateCells(at: revealedIndexPaths)
        }
    }
    
    func onCellHighlight(_ highlightedCells: Set<Int>) {
        let highlightIndexPaths = highlightedCells.map { return IndexPath(row: $0, section: 0) }
        
        DispatchQueue.main.async {
            self.minefieldView.updateCells(at: highlightIndexPaths)
        }
    }
    
    func onCellFlagged(_ flaggedCell: Int) {
        DispatchQueue.main.async {
            self.minefieldView.updateCells(at: [IndexPath(row: flaggedCell, section: 0)])
            
            self.game?.minesRemaining -= 1
            
            self.updateRemainingMinesCountLabel()
        }
    }
    
    func onCellUnflagged(_ unflaggedCell: Int) {
        DispatchQueue.main.async {
            self.minefieldView.updateCells(at: [IndexPath(row: unflaggedCell, section: 0)])
            
            self.game?.minesRemaining += 1
            
            self.updateRemainingMinesCountLabel()
        }
    }
    
    func onCellExploded(_ explodedCell: Int) {
        DispatchQueue.main.async {
            self.minefieldView.updateCells(at: [IndexPath(row: explodedCell, section: 0)])
            
            self.gameOver()
        }
    }
    
    func onGameCompleted() {
        DispatchQueue.main.async {
            self.gameCompleted()
        }
    }
}
