//
//  Constants.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/28/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class Constants {
    static let primaryColor: UIColor = UIColor.white
    static let accentColor: UIColor = UIColor(rgb: 0x990000)
    
    static let brickTileIconName = "brick-tile-icon"
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
    
    static let cellSpacing = CGFloat(0)
    static let defaultCellDimension = CGFloat(42)
    
    static let defaultMinScaleFactor: CGFloat = 1
    static let defaultMaxScaleFactor: CGFloat = 3
    static let fieldBorderWidth: CGFloat = 2
}
