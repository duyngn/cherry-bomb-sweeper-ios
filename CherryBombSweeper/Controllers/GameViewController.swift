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
    @IBOutlet private weak var statsContainer: UIView!
    
    @IBOutlet fileprivate weak var timerLabel: UILabel!
    @IBOutlet private weak var mineCountLabel: UILabel!
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet private weak var actionModeButton: UIButton!
    
    // Grid
    @IBOutlet fileprivate weak var mineFieldView: FieldGridScrollView!

    fileprivate var game: Game?
    fileprivate var isFieldInit: Bool = true
    
    private var currentOrientation: UIDeviceOrientation = .portrait
    private var currentUserAction: UserAction = .tap
    
    fileprivate var gameGeneratorService: GameGeneratorService = GameGeneratorService()
    private var gameProcessingService: GameProcessingService = GameProcessingService()
    private var gameTimer: GameTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bkgPattern = GameGeneralService.shared.brickTileImage {
            self.view.backgroundColor = UIColor.init(patternImage: bkgPattern)
        }
        
        self.setupOrientationHandler()
        
        self.gameTimer = GameTimer(self)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.statsContainer.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.statsContainer.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.statsContainer.insertSubview(blurEffectView, at: 0)
        }
    }
    
    lazy private var initGame: Void = {
        self.gameProcessingService.registerListener(self)
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
    
    private func setupOrientationHandler() {
        self.currentOrientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: .main)
        { [weak self] (notification) in
            guard let `self` = self else { return }
            
            if self.currentOrientation != UIDevice.current.orientation {
                switch UIDevice.current.orientation {
                case .landscapeLeft, .landscapeRight,
                     .portrait, .portraitUpsideDown:
                    self.mineFieldView.calculateGridLayoutParams()
                    self.currentOrientation = UIDevice.current.orientation
                default:
                    break
                }
            }
        }
    }
    
    private func setupFieldGridView() {
        DispatchQueue.main.async {
            let actionableState: Set<GameState> = Set([.loaded, .new, .inProgress])
            
            var rowCount = 0
            var colCount = 0
            if let game = self.game {
                rowCount = game.mineField.rows
                colCount = game.mineField.columns
            } else {
                let gameOptions = PersistableService.getGameOptionsFromUserDefaults()
                rowCount = gameOptions.rowCount
                colCount = gameOptions.columnCount
            }
            
            self.mineFieldView.setupFieldGrid(rows: rowCount,
                                              columns: colCount,
                                              dataSource: self,
                                              cellTapHandler: { [weak self] (cellIndex) in
                                                
                guard let `self` = self, let game = self.game else { return }
                                                
                if actionableState.contains(game.state) {
                    self.gameStarted()
                    
                    self.gameProcessingService.resolveUserAction(at: cellIndex, in: game, with: self.currentUserAction)
                }
            }) { (_, _) in
//                let _ = self.mineFieldView.recenterFieldGrid()
            }
        }
    }
    
    private func startNewGame() {
        self.isFieldInit = true
        self.game = nil
        
        self.resetControlStates()
        self.resetGameTimer()
        self.setupFieldGridView()
        
        gameGeneratorService.generateNewGame { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            newGame.state = .loaded
            self.game = newGame
            
            DispatchQueue.main.async {
                self.mineCountLabel.text = String(describing: newGame.mineField.mines)
            }
            
            self.finishLoading()
        }
    }
    
    private func resetGameTimer() {
        self.timerLabel.text = "00:00"
        
        self.gameTimer?.resetTimer()
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
        if let gameTimer = self.gameTimer {
            gameTimer.restartTimer()
        }
    }
    
    fileprivate func gameOver() {
        self.gameTimer?.pauseTimer()
        
        DispatchQueue.main.async {
            self.game?.state = .lost
            
            if let boomImage = GameGeneralService.shared.boomImage {
                self.newGameButton.setImage(boomImage, for: UIControlState.normal)
                self.newGameButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
            
            self.mineFieldView.showEntireField()
            
            // Preload the next game
            self.gameGeneratorService.preloadGame()
        }
    }
    
    fileprivate func gameCompleted() {
        self.gameTimer?.pauseTimer()
        
        DispatchQueue.main.async {
            self.game?.state = .win
            
            self.mineFieldView.showEntireField()
            
            // Preload the next game
            self.gameGeneratorService.preloadGame()
        }
    }
    
    private func finishLoading() {
        self.isFieldInit = false
    }
    
    @IBAction func onOptionsPressed(_ sender: UIButton) {
        self.gameTimer?.pauseTimer()
        
        let optionsController = OptionsViewController(nibName: "OptionsViewController", bundle: nil)
        optionsController.exitHandler = { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            if newGame {
                self.startNewGame()
            } else if self.game?.state == .inProgress {
                self.gameTimer?.resumeTimer()
            }
        }
        
        optionsController.modalPresentationStyle = .overFullScreen
        
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
        return self.game?.mineField.cellIndexToCoordMap.count ?? self.gameGeneratorService.gameOptions.rowCount * self.gameGeneratorService.gameOptions.columnCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: FieldGridCollectionView.Constant.gridCellIdentifier, for: indexPath) as? FieldGridCell {
            
            if self.isFieldInit {
                cellView.reinitCell(at: indexPath.row, fieldRows: self.gameGeneratorService.gameOptions.rowCount)
            } else if let game = self.game, let cell = game.mineField.getCell(at: indexPath.row) {
                cellView.setupCellView(with: cell)
            }
            
            return cellView
        }
        
        let cellView = FieldGridCell()
        cellView.reinitCell(at: indexPath.row, fieldRows: self.gameGeneratorService.gameOptions.rowCount)
        return cellView
    }
}

extension GameViewController: GameTimerDelegate {
    func onTimerUpdate(seconds: Int, timeString: String) {
        self.timerLabel.text = timeString
    }
}

extension GameViewController: GameStatusListener {
    func onCellReveal(_ revealedCells: Set<Int>) {
        let revealedIndexPaths = revealedCells.map { return IndexPath(row: $0, section: 0) }
        self.mineFieldView.updateCells(at: revealedIndexPaths)
    }
    
    func onCellHighlight(_ highlightedCells: Set<Int>) {
        let highlightIndexPaths = highlightedCells.map { return IndexPath(row: $0, section: 0) }
        
        self.mineFieldView.updateCells(at: highlightIndexPaths)
        
        // Now reset them to untouched
        DispatchQueue.main.async {
            for cellId in highlightedCells {
                if let cell = self.game?.mineField.getCell(at: cellId), cell.state == .highlight {
                    cell.state = .untouched
                    self.game?.mineField.updateCell(cell)
                }
            }
            
            self.mineFieldView.updateCells(at: highlightIndexPaths)
        }
    }
    
    func onCellFlagged(_ flaggedCell: Int) {
        self.mineFieldView.updateCells(at: [IndexPath(row: flaggedCell, section: 0)])

        self.updateRemainingMinesCountLabel()
    }
    
    func onCellUnflagged(_ unflaggedCell: Int) {
        self.mineFieldView.updateCells(at: [IndexPath(row: unflaggedCell, section: 0)])
        
        self.updateRemainingMinesCountLabel()
    }
    
    func onCellExploded(_ explodedCell: Int, otherBombCells: Set<Int>, wrongFlaggedCells: Set<Int>) {
        var cellsToUpdate = otherBombCells.map { return IndexPath(row: $0, section: 0) }
        cellsToUpdate.append(contentsOf: wrongFlaggedCells.map { return IndexPath(row: $0, section: 0) })
        
        self.mineFieldView.updateCells(at: cellsToUpdate)
        
        // Ensure this gets rendered last
        DispatchQueue.main.async {
            self.mineFieldView.updateCells(at: [IndexPath(row: explodedCell, section: 0)])
        }
        
        self.gameOver()
    }
    
    func onGameCompleted() {
        self.gameCompleted()
    }
}
