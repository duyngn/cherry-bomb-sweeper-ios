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
    @IBOutlet private weak var flagButton: UIButton!
    
    // Grid
    @IBOutlet fileprivate weak var fieldGridView: FieldGridCollectionView!
    @IBOutlet private weak var fieldContainer: UIView!
    
    fileprivate var gameOptions: GameOptions = GameServices.shared.gameOptions
    fileprivate var game: Game?
    
    private var currentUserAction: UserAction = .tap
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fieldGridView.isHidden = true
    }
    
    lazy private var initGame: Void = {
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
            self.fieldGridView.setupFieldGrid(with: game.mineField, containerView: self.fieldContainer, dataSource: self) { [weak self] (cellIndex) in
                guard let `self` = self else { return }
                
                self.gameStarted()
                
                GameServices.shared.resolveUserAction(at: cellIndex, in: game, with: self.currentUserAction) { [weak self] (modifiedCell) in
                    guard let `self` = self else { return }
                    
                    DispatchQueue.main.async {
                        self.fieldGridView.reloadItems(at: [IndexPath(row: modifiedCell.id, section: 0)])
                    }
                }
            }
        }
    }
    
    private func startNewGame() {
        GameServices.shared.generateNewGame { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            newGame.state = .loaded
            
            self.game = newGame
            
            self.setupFieldGridView()
        }
    }
    
    private func gameStarted() {
        self.game?.state = .inProgress
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
        self.currentUserAction = action
        
        switch self.currentUserAction {
        case .flag:
            self.flagButton.setTitle("Flag", for: UIControlState.normal)
        case .tap:
            self.flagButton.setTitle("Tap", for: UIControlState.normal)
        }
    }
}

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.game?.mineField.cellCoordMap.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: FieldGridCollectionView.Constant.gridCellIdentifier, for: indexPath) as? FieldGridCell, let game = self.game, let cell = game.mineField.getCell(at: indexPath.row) {
     
            cellView.setupCellView(with: cell)
            
            return cellView
        }
        
        return FieldGridCell()
    }
}
