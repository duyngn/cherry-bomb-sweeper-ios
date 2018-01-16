//
//  FieldGridCell.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/13/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class FieldGridCell: UICollectionViewCell {

    enum Constants {
        static let defaultFontSize: CGFloat = 25
        
        static let numberColors: [UIColor] = [
            UIColor.init(red: 0, green: 0, blue: 0, alpha: 0), // 0, transparent
            UIColor.init(rgb: 0x0000FF),    // 1, blue
            UIColor.init(rgb: 0x187B00),    // 2, green
            UIColor.init(rgb: 0xFA1000),    // 3, red
            UIColor.init(rgb: 0x000081),    // 4, purple
            UIColor.init(rgb: 0x780200),    // 5, maroon
            UIColor.init(rgb: 0x40e0d0),    // 6, turquoise
            UIColor.gray,                   // 7, gray
            UIColor.black                   // 8, black
        ]
    }
    
    @IBOutlet private weak var adjacentBombsLabel: UILabel!
    @IBOutlet private weak var cellIcon: UIImageView!
    
    private var scaledFactor: CGFloat = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cellIcon.isHidden = true
        self.adjacentBombsLabel.isHidden = true
    }
    
    func setupCellView(with cell: Cell) {
//        self.scaledFactor = scaledFactor
        
        if cell.hasBomb {
            self.cellIcon.isHidden = false
        } else if cell.adjacentBombs > 0 {
            self.setAdjacentBombsCount(cell.adjacentBombs)
        }
    }
    
    private func setAdjacentBombsCount(_ count: Int) {
        let numberColor = (count > 0 && count < Constants.numberColors.count)
            ? Constants.numberColors[count]
            : Constants.numberColors[0] // transparent
        
//        let fontSize = self.scaledFactor * Constants.defaultFontSize
//        self.adjacentBombsLabel.font = self.adjacentBombsLabel.font.withSize(fontSize)
       
        self.adjacentBombsLabel.textColor = numberColor
        self.adjacentBombsLabel.text = String(describing: count)
        self.adjacentBombsLabel.isHidden = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellIcon.isHidden = true
        self.adjacentBombsLabel.isHidden = true
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
