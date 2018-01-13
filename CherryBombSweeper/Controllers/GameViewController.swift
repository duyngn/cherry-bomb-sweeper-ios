//
//  GameViewController.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    private var gameOptions: GameOptions = GameServices.shared.gameOptions
    private var game: Game?
    
    private lazy var initGame: Void = {
        GameServices.shared.generateNewGame { [weak self] (newGame) in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                self.testLabel.text = newGame.mineField.describe()
            }
        }
    }()
    
    @IBOutlet weak var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Game View Controller"
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let _ = initGame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
