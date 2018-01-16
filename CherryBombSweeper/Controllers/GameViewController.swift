//
//  GameViewController.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet fileprivate weak var fieldGridView: FieldGridCollectionView!
    @IBOutlet private weak var fieldContainer: UIView!
    
    fileprivate var gameOptions: GameOptions = GameServices.shared.gameOptions
    fileprivate var game: Game = Game()
    
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
        
        let _ = self.initGame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
            self.fieldGridView.setupFieldGrid(with: self.game.mineField, containerView: self.fieldContainer, dataSource: self)
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.game.mineField.cellCoordMap.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: FieldGridCollectionView.Constants.gridCellIdentifier, for: indexPath) as? FieldGridCell {
            if let cellCoord = self.game.mineField.cellCoordMap[indexPath.row] {
                let cell = self.game.mineField.fieldGrid[cellCoord.row][cellCoord.column]
                
                cellView.setupCellView(with: cell)
            }
            
            return cellView
        }
        
        return FieldGridCell()
    }
}
