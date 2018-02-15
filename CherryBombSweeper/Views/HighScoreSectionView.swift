//
//  HighScoreSectionView.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 2/11/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class HighScoreSectionView: UIView {

    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var sectionTitle: UILabel!
    @IBOutlet private weak var firstPlace: UILabel!
    @IBOutlet private weak var secondPlace: UILabel!
    @IBOutlet private weak var thirdPlace: UILabel!
    
    static func instanceFromNib() -> HighScoreSectionView? {
        return Bundle.main.loadNibNamed("HighScoreSectionView", owner: nil, options: nil)?.first as? HighScoreSectionView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setTitle(title: String) {
        self.sectionTitle.text = title
    }
}
