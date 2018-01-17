//
//  HomeMenuViewController.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class HomeMenuViewController: UIViewController {

    @IBOutlet private weak var gridSizeLabel: UILabel!
    @IBOutlet private weak var minesCountLabel: UILabel!
    
    lazy private var preloadGame: Void = {
        GameServices.shared.preloadGame()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let _ = preloadGame
    }
    
    private func updateGameConfigLabels() {
        self.gridSizeLabel.text = "\(GameServices.shared.gameOptions.rowCount) x \(GameServices.shared.gameOptions.columnCount)"
        self.minesCountLabel.text = "\(GameServices.shared.gameOptions.minesCount) Mines"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.updateGameConfigLabels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func onNewGamePressed(_ sender: UIButton) {
        // Launch a new game
        self.navigationController?.pushViewController(GameViewController(), animated: true)
    }
    
    @IBAction func onOptionsPressed(_ sender: UIButton) {
        // Launch the options controller
        self.navigationController?.pushViewController(OptionsViewController(), animated: true)
    }
}
