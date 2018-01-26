//
//  GameGeneralService.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/21/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation
import UIKit

class GameGeneralService {
    
    enum Constant {
        static let darkGrassIconName = "grass-dark-icon"
        static let lightGrassIconName = "grass-light-icon"
        static let flagIconName = "flag-icon"
        static let shovelIconName = "shovel-icon"
        static let boomIconName = "boom-icon"
        static let bombIconName = "cherry-bomb-icon"
        static let gearIconName = "gear-icon"
        static let xIconName = "x-icon"
        
        static let defaultMines: Int = 10
        static let minimumMines: Int = 10
        static let maximumMines: Int = 200
        
        static let defaultRows: Int = 9
        static let defaultColumns: Int = 9
        static let minimumFieldDimension: Int = 9
        static let maximumFieldDimension: Int = 30

        static let cellSpacing = CGFloat(1)
        static let defaultCellDimension = CGFloat(41)
        
        static let defaultMinScaleFactor: CGFloat = 1
        static let defaultMaxScaleFactor: CGFloat = 3
        static let fieldBorderWidth: CGFloat = 2
    }
    
    static let shared = GameGeneralService()
    
    var darkGrassImage: UIImage?
    var lightGrassImage: UIImage?
    var flagImage: UIImage?
    var shovelImage: UIImage?
    var boomImage: UIImage?
    var bombImage: UIImage?
    var gearImage: UIImage?
    var xImage: UIImage?
    
    fileprivate init() {
        self.darkGrassImage = UIImage(named: Constant.darkGrassIconName)
        self.lightGrassImage = UIImage(named: Constant.lightGrassIconName)
        self.flagImage = UIImage(named: Constant.flagIconName)
        self.shovelImage = UIImage(named: Constant.shovelIconName)
        self.boomImage = UIImage(named: Constant.boomIconName)
        self.bombImage = UIImage(named: Constant.bombIconName)
        self.gearImage = UIImage(named: Constant.gearIconName)
        self.xImage = UIImage(named: Constant.xIconName)
    }
}
