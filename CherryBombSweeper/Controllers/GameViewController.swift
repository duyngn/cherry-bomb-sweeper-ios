//
//  GameViewController.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

enum UserAction {
    case reveal
    case probe
    case flag
}

typealias CellTapHandler = (_ cellIndex: Int) -> Void

class GameViewController: UIViewController {

    // Controls
    @IBOutlet private weak var revealButton: UIButton!
    @IBOutlet private weak var probeButton: UIButton!
    @IBOutlet private weak var flagButton: UIButton!
    
    // Grid
    @IBOutlet fileprivate weak var fieldGridView: FieldGridCollectionView!
    @IBOutlet private weak var fieldContainer: UIView!
    
    fileprivate var gameOptions: GameOptions = GameServices.shared.gameOptions
    fileprivate var game: Game?
    
    private var currentUserAction: UserAction = .reveal    // The first user action should always be reveal
    
    private lazy var initGame: Void = {
        GameServices.shared.generateNewGame { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            self.game = newGame
            
            self.setupFieldGridView()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fieldGridView.isHidden = true
        self.navigationItem.title = "Game View Controller"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.updateCurrentAction(to: self.currentUserAction)
        
        let _ = self.initGame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupFieldGridView() {
        guard let game = self.game else { return }
        
        DispatchQueue.main.async {
            self.fieldGridView.setupFieldGrid(with: game.mineField, containerView: self.fieldContainer, dataSource: self) { [weak self] (cellIndex) in
                guard let `self` = self, let game = self.game else { return }
                
                GameServices.resolveUserAction(at: cellIndex, in: game.mineField, with: self.currentUserAction) { [weak self] (modifiedCell) in
                    guard let `self` = self else { return }
                    
                    DispatchQueue.main.async {
                        self.fieldGridView.reloadItems(at: [IndexPath(row: modifiedCell.id, section: 0)])
                    }
                }
            }
        }
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRevealPressed(_ sender: UIButton) {
        self.updateCurrentAction(to: .reveal)
    }
    
    @IBAction func onProbePressed(_ sender: UIButton) {
        self.updateCurrentAction(to: .probe)
    }
    
    @IBAction func onFlagPressed(_ sender: UIButton) {
        self.updateCurrentAction(to: .flag)
    }
    
    private func updateCurrentAction(to action: UserAction) {
        self.currentUserAction = action
        
        var button: UIButton = self.revealButton
        switch action {
        case .reveal:
            self.probeButton.titleLabel?.attributedText = nil
            self.probeButton.titleLabel?.text = "Probe"
            
            self.flagButton.titleLabel?.attributedText = nil
            self.flagButton.titleLabel?.text = "Flag"
        case .probe:
            button = self.probeButton
            self.revealButton.titleLabel?.attributedText = nil
            self.revealButton.titleLabel?.text = "Reveal"
            
            self.flagButton.titleLabel?.attributedText = nil
            self.flagButton.titleLabel?.text = "Flag"
        case .flag:
            button = self.flagButton
            self.revealButton.titleLabel?.attributedText = nil
            self.revealButton.titleLabel?.text = "Reveal"
            
            self.probeButton.titleLabel?.attributedText = nil
            self.probeButton.titleLabel?.text = "Probe"
        }
        
        if let buttonLabel = button.titleLabel, let text = buttonLabel.text {
            let textRange = NSMakeRange(0, text.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            buttonLabel.attributedText = attributedText
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
