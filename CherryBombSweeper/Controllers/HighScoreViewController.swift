//
//  HighScoreViewController.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 2/11/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class HighScoreViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var highScoresTitle: UILabel!
    
    var exitHandler: EmptyCompletionHandler?
    
    lazy private var loadOnce: Void = {
        if let highScoreSection = HighScoreSectionView.instanceFromNib() {
            highScoreSection.setTitle(title: "Test Title!")
            
            self.container.addSubview(highScoreSection)
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.insertSubview(blurEffectView, at: 0)
        }
        
        let _ = loadOnce
    }
    
    private func fetchAllStats() {
    
    }
    
    private func addHighScoreSection() {
        
    }
    
    @IBAction func onCloseButtonPressed(_ sender: UIButton) {
        AudioService.shared.playRevealSound()
        
        self.scrollView.alpha = 0
        self.exitHandler?()
        
        self.dismiss(animated: true)
    }
}
