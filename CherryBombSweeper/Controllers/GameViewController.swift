//
//  GameViewController.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit
import AVFoundation

enum UserAction {
    case tap
    case flag
}

class GameViewController: UIViewController {
    
    @IBOutlet private weak var splashImage: UIImageView!
    
    // Controls
    @IBOutlet private weak var controlsContainer: UIView!
    @IBOutlet private weak var statsContainer: UIView!
    
    @IBOutlet fileprivate weak var timerLabel: UILabel!
    @IBOutlet private weak var mineCountLabel: UILabel!
    
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet private weak var actionModeButton: UIButton!
    
    // Grid
    @IBOutlet fileprivate weak var mineFieldView: FieldGridScrollView!

    fileprivate var game: Game?
    fileprivate var isFieldInit: Bool = true
    
    private var currentOrientation: UIDeviceOrientation = .portrait
    fileprivate var currentUserAction: UserAction = .tap
    fileprivate let actionableState: Set<GameState> = Set([.loaded, .new, .inProgress])
    
    fileprivate var gameGeneratorService: GameGeneratorService = GameGeneratorService()
    fileprivate var gameProcessingService: GameProcessingService = GameProcessingService()
    private var gameTimer: GameTimer?
    
    fileprivate var audioService: AudioService = AudioService.shared
    
    lazy private var initGame: Void = {
        self.gameProcessingService.registerListener(self)
        self.showSplashImage()
        
        self.startNewGame()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bkgPattern = GameIconsService.shared.brickTileImage {
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
    
    private func showSplashImage() {
        self.splashImage.alpha = 0
        self.splashImage.isHidden = false
        
        self.splashImage.startRotating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.splashImage.alpha = 1
        }
    }
    
    private func hideSplashImage() {
        self.splashImage.alpha = 1
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.splashImage.alpha = 0
            self.splashImage.transform = CGAffineTransform(scaleX: 0.15, y: 0.15)
        }) { [weak self] (_) in
            guard let `self` = self else { return }
            
            self.splashImage.isHidden = true
            self.splashImage.transform = CGAffineTransform.identity
            self.splashImage.stopRotating()
        }
    }
    
    private func setupFieldGridView() {
        DispatchQueue.main.async {
            
            var rowCount = 0
            var colCount = 0
            if let game = self.game {
                rowCount = game.mineField.rows
                colCount = game.mineField.columns
            } else {
                let gameOptions = PersistableService.getGameOptions()
                rowCount = gameOptions.rowCount
                colCount = gameOptions.columnCount
            }
            
            self.mineFieldView.setupFieldGrid(rows: rowCount, columns: colCount, dataSource: self, cellActionHandler: self) { (_, _) in
                self.audioService.playBeepBeepSound()
                self.hideSplashImage()
            }
        }
    }
    
    private func startNewGame() {
        self.audioService.startBackgroundMusic()
        
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
        
        self.timerLabel.textColor = Constants.primaryColor
        self.mineCountLabel.textColor = Constants.primaryColor
        UIView.animate(withDuration: 0.3) {
            self.timerLabel.transform = CGAffineTransform.identity
        }
        
        if let bombImage = GameIconsService.shared.bombImage {
            self.newGameButton.setImage(bombImage, for: UIControlState.normal)
        }
        
        self.newGameButton.transform = CGAffineTransform.identity
    }
    
    fileprivate func gameStarted() {
        guard let game = self.game, game.state != .inProgress else { return }
        
        self.game?.state = .inProgress
        if let gameTimer = self.gameTimer {
            gameTimer.restartTimer()
        }
    }
    
    fileprivate func gameOver() {
        self.gameTimer?.pauseTimer()
        self.audioService.stopBackgroundMusic()
        self.audioService.playExplodeSound()
        
        DispatchQueue.main.async {
            self.game?.state = .lost
            
            if let boomImage = GameIconsService.shared.boomImage {
                self.newGameButton.setImage(boomImage, for: UIControlState.normal)
                self.newGameButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
            
            self.timerLabel.textColor = Constants.heavyAccentColor
            self.mineCountLabel.textColor = Constants.heavyAccentColor
            UIView.animate(withDuration: 0.2, animations: {
                self.timerLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5).rotated(by: .pi * -0.15)
            })
            
            self.mineFieldView.showEntireField()
            
            // Preload the next game
            self.gameGeneratorService.preloadGame()
        }
    }
    
    fileprivate func gameFinished() {
        self.gameTimer?.pauseTimer()
        self.audioService.stopBackgroundMusic()
        self.audioService.playWinningMusic()
        
        DispatchQueue.main.async {
            self.game?.state = .win
            
            self.timerLabel.textColor = Constants.accentColor
            self.mineCountLabel.textColor = Constants.accentColor
            UIView.animate(withDuration: 0.2, animations: {
                self.timerLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5).rotated(by: .pi * -0.15)
            })
            
            self.mineFieldView.showEntireField()
            
            // Preload the next game
            self.gameGeneratorService.preloadGame()
        }
    }
    
    private func pauseGame() {
        self.audioService.stopBackgroundMusic()
        
        guard let game = self.game, game.state == .inProgress else { return }
        
        self.gameTimer?.pauseTimer()
        self.game?.state = .paused
    }
    
    private func unpauseGame() {
        guard let game = self.game else { return }
        
        switch game.state {
        case .lost, .win:
            return
        case .paused:
            game.state = .inProgress
            
            self.gameTimer?.resumeTimer()
        default:
            break
        }
        
        self.audioService.startBackgroundMusic()
    }
    
    private func finishLoading() {
        self.isFieldInit = false
    }
    
    private func updateActionModeButton(to action: UserAction) {
        DispatchQueue.main.async {
            self.currentUserAction = action
            
            switch self.currentUserAction {
            case .flag:
                if let flagImage = GameIconsService.shared.flagImage {
                    self.actionModeButton.setImage(flagImage, for: UIControlState.normal)
                }
            case .tap:
                if let shovelImage = GameIconsService.shared.shovelImage {
                    self.actionModeButton.setImage(shovelImage, for: UIControlState.normal)
                }
            }
        }
    }
    
    fileprivate func updateRemainingMinesCountLabel() {
        if let minesCount = self.game?.minesRemaining {
            
            DispatchQueue.main.async {
                self.mineCountLabel.text = String(describing: minesCount)
                self.mineCountLabel.textColor = Constants.accentColor
                self.mineCountLabel.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                
                UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
                    self.mineCountLabel.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    self.mineCountLabel.textColor = Constants.primaryColor
                })
            }
        }
    }
    
    @IBAction func onActionModePressed(_ sender: UIButton) {
        self.audioService.playPositiveSound()
        self.updateActionModeButton(to: (self.currentUserAction == .tap) ? .flag : .tap)
    }
    
    @IBAction func onNewGamePressed(_ sender: UIButton) {
        self.audioService.playSaveConfigSound()
        
        self.startNewGame()
    }
    
    @IBAction func onOptionsPressed(_ sender: UIButton) {
        self.audioService.playPositiveSound()
        
        self.pauseGame()
        
        let optionsController = OptionsViewController(nibName: "OptionsViewController", bundle: nil)
        optionsController.exitHandler = { [weak self] (newGame) in
            guard let `self` = self else { return }

            if newGame {
                self.startNewGame()
            } else {
                self.unpauseGame()
            }
        }
        
        optionsController.modalPresentationStyle = .overFullScreen
        
        self.present(optionsController, animated: true)
    }
}

extension GameViewController: GameTimerDelegate {
    func onTimerUpdate(seconds: Int, timeString: String) {
        self.timerLabel.text = timeString
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

extension GameViewController: FieldGridCellActionListener {
    func onCellTap(_ cellIndex: Int) {
        guard let game = self.game else { return }
        
        if actionableState.contains(game.state) {
            self.audioService.playTapSound()
            
            self.gameStarted()
            
            self.gameProcessingService.resolveUserAction(at: cellIndex, in: game, with: self.currentUserAction)
        }
    }
    
    func onCellHighlight(_ cellIndex: Int) {
        guard let game = self.game else { return }
        
        if actionableState.contains(game.state) {
            self.gameProcessingService.resolveUserAction(at: cellIndex, in: game, with: self.currentUserAction)
        }
    }
    
    func onCellUnhighlight(_ cellIndex: Int) {
        guard let game = self.game else { return }
        
        if actionableState.contains(game.state) {
            self.gameProcessingService.resolveUserAction(at: cellIndex, in: game, with: self.currentUserAction)
        }
    }
    
    func onCellLongPress(_ cellIndex: Int) {
        guard let game = self.game else { return }
        
        if actionableState.contains(game.state) {
            self.gameStarted()
            
            self.gameProcessingService.resolveUserAction(at: cellIndex, in: game, with: .flag)
        }
    }
    
    func onCellHardPress(_ cellIndex: Int) {
        
    }
}

extension GameViewController: GameStatusListener {
    func cellsRevealed(_ revealedCells: Set<Int>) {
        let revealedIndexPaths = revealedCells.map { return IndexPath(row: $0, section: 0) }
        self.mineFieldView.updateCells(at: revealedIndexPaths)
        
        self.audioService.playRevealSound()
    }
    
    func cellsHighlighted(_ highlightedCells: Set<Int>) {
        let highlightIndexPaths = highlightedCells.map { return IndexPath(row: $0, section: 0) }
        
        self.mineFieldView.updateCells(at: highlightIndexPaths)
        
        self.audioService.playProbeSound()
        
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
    
    func cellsUnhighlighted(_ unhighlightedCells: Set<Int>) {
        let unhighlightIndexPaths = unhighlightedCells.map { return IndexPath(row: $0, section: 0) }
        
        self.mineFieldView.updateCells(at: unhighlightIndexPaths)
    }
    
    func cellFlagged(_ flaggedCell: Int) {
        self.mineFieldView.updateCells(at: [IndexPath(row: flaggedCell, section: 0)])

        self.updateRemainingMinesCountLabel()
        
        self.audioService.playFlagSound()
    }
    
    func cellUnflagged(_ unflaggedCell: Int) {
        self.mineFieldView.updateCells(at: [IndexPath(row: unflaggedCell, section: 0)])
        
        self.updateRemainingMinesCountLabel()
        
        self.audioService.playFlagSound()
    }
    
    func cellExploded(_ explodedCell: Int, otherBombCells: Set<Int>, wrongFlaggedCells: Set<Int>) {
        var cellsToUpdate = otherBombCells.map { return IndexPath(row: $0, section: 0) }
        cellsToUpdate.append(contentsOf: wrongFlaggedCells.map { return IndexPath(row: $0, section: 0) })
        
        self.mineFieldView.updateCells(at: cellsToUpdate)
        
        // Ensure this gets rendered last
        DispatchQueue.main.async {
            self.mineFieldView.updateCells(at: [IndexPath(row: explodedCell, section: 0)])
        }
        
        self.gameOver()
    }
    
    func gameCompleted() {
        self.gameFinished()
    }
}
