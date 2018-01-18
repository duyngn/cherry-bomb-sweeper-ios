//
//  GameViewController.swift
//  C4Sweeper
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
    @IBOutlet private weak var minesRemainingLabel: UIButton!
    @IBOutlet private weak var flagButton: UIButton!
    
    // Grid
    @IBOutlet fileprivate weak var fieldGridView: FieldGridCollectionView!
//    @IBOutlet private weak var fieldContainer: UIView!
    
    fileprivate var gameOptions: GameOptions = GameGeneratorService.shared.gameOptions
    fileprivate var game: Game?
    
    private var currentUserAction: UserAction = .tap
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fieldGridView.isHidden = true
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
        guard let game = self.game else { return }
        
        DispatchQueue.main.async {
            let actionableState: Set<GameState> = Set([.loaded, .new, .inProgress])
            
            self.fieldGridView.setupFieldGrid(with: game.mineField, dataSource: self) { [weak self] (cellIndex) in
                guard let `self` = self else { return }
                
                if actionableState.contains(game.state) {
                    self.gameStarted()
                    
                    GameProcessingService.shared.resolveUserAction(at: cellIndex, in: game, with: self.currentUserAction)
                }
            }
        }
    }
    
    private func startNewGame() {
        GameGeneratorService.shared.generateNewGame { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            newGame.state = .loaded
            
            self.game = newGame
            
            self.updateRemainingMinesCountLabel()
            self.setupFieldGridView()
        }
    }
    
    private func gameStarted() {
        guard let game = self.game, game.state != .inProgress else { return }
        
        self.game?.state = .inProgress
    }
    
    fileprivate func gameOver() {
        DispatchQueue.main.async {
            self.game?.state = .lost
            
            self.minesRemainingLabel.setTitle("GAME OVER", for: UIControlState.normal)
        }
    }
    
    fileprivate func gameCompleted() {
        DispatchQueue.main.async {
            self.game?.state = .win
            
            self.minesRemainingLabel.setTitle("WINNER", for: UIControlState.normal)
        }
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onActionModePressed(_ sender: UIButton) {
        self.updateActionModeButton(to: (self.currentUserAction == .tap) ? .flag : .tap)
    }
    
    @IBAction func onNewGamePressed(_ sender: UIButton) {
        self.startNewGame()
        self.updateActionModeButton(to: .tap)
    }
    
    private func updateActionModeButton(to action: UserAction) {
        DispatchQueue.main.async {
            self.currentUserAction = action
            
            switch self.currentUserAction {
            case .flag:
                self.flagButton.setTitle("Flag", for: UIControlState.normal)
            case .tap:
                self.flagButton.setTitle("Tap", for: UIControlState.normal)
            }
        }
    }
    
    fileprivate func updateRemainingMinesCountLabel() {
        if let minesCount = self.game?.minesRemaining {
            DispatchQueue.main.async {
                self.minesRemainingLabel.setTitle(String(describing: minesCount), for: UIControlState.normal)
            }
        }
    }
}

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.game?.mineField.cellIndexToCoordMap.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: FieldGridCollectionView.Constant.gridCellIdentifier, for: indexPath) as? FieldGridCell, let game = self.game, let cell = game.mineField.getCell(at: indexPath.row) {
     
            cellView.setupCellView(with: cell)
            
            return cellView
        }
        
        return FieldGridCell()
    }
}

extension GameViewController: GameStatusListener {
    func onCellReveal(_ revealedCells: Set<Int>) {
        let revealedIndexPaths = revealedCells.map { return IndexPath(row: $0, section: 0) }
        
        DispatchQueue.main.async {
            self.fieldGridView.reloadItems(at: revealedIndexPaths)
        }
    }
    
    func onCellHighlight(_ highlightedCells: Set<Int>) {
        let highlightIndexPaths = highlightedCells.map { return IndexPath(row: $0, section: 0) }
        
        DispatchQueue.main.async {
            self.fieldGridView.reloadItems(at: highlightIndexPaths)
        }
    }
    
    func onCellFlagged(_ flaggedCell: Int) {
        DispatchQueue.main.async {
            self.fieldGridView.reloadItems(at: [IndexPath(row: flaggedCell, section: 0)])
            
            self.game?.minesRemaining -= 1
            
            self.updateRemainingMinesCountLabel()
        }
    }
    
    func onCellUnflagged(_ unflaggedCell: Int) {
        DispatchQueue.main.async {
            self.fieldGridView.reloadItems(at: [IndexPath(row: unflaggedCell, section: 0)])
            
            self.game?.minesRemaining += 1
            
            self.updateRemainingMinesCountLabel()
        }
    }
    
    func onCellExploded(_ explodedCell: Int) {
        DispatchQueue.main.async {
            self.fieldGridView.reloadItems(at: [IndexPath(row: explodedCell, section: 0)])
            
            self.gameOver()
        }
    }
    
    func onGameCompleted() {
        DispatchQueue.main.async {
            self.gameCompleted()
        }
    }
}
