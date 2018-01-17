//
//  FieldGridCell.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/13/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class FieldGridCell: UICollectionViewCell {

    enum Constant {
        static let defaultFontSize: CGFloat = 25
        static let grassLightIconId: String = "grass-light-cell"
        static let grassDarkIconId: String = "grass-dark-cell"
        static let boomIconId: String = "boom-icon"
        
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
    
    @IBOutlet private weak var cellFlagIcon: UIImageView!
    @IBOutlet private weak var cellCover: UIImageView!
    @IBOutlet private weak var adjacentBombsLabel: UILabel!
    @IBOutlet private weak var cellIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cellFlagIcon.isHidden = true
        self.cellCover.isHidden = false
        self.cellIcon.isHidden = true
        self.adjacentBombsLabel.isHidden = true
    }
    
    func setupCellView(with cell: Cell) {
    
        switch cell.state {
        case .untouched:
            if let image = self.getCellCoverGrass(for: cell) {
                self.cellCover.image = image
            }
        case .revealed:
            if cell.adjacentBombs > 0 {
                self.setAdjacentBombsCount(cell.adjacentBombs)
            }
            
            self.cellCover.isHidden = true
        case .flagged:
            self.cellFlagIcon.isHidden = false
            
            if let image = self.getCellCoverGrass(for: cell) {
                self.cellCover.image = image
            }
        case .exploded:
            if let image = UIImage(named: Constant.boomIconId) {
                self.cellCover.image = image
                self.cellCover.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
        case .highlight:
            break
        case .showBomb:
            break
        }
    }
    
    private func getCellCoverGrass(for cell: Cell) -> UIImage? {
        let row = cell.fieldCoord.row
        let column = cell.fieldCoord.column
        
        if row % 2 == 0 { // row starts with light color
            if column % 2 == 0, let image = UIImage(named: Constant.grassLightIconId) {
                return image
            } else if let image = UIImage(named: Constant.grassDarkIconId) {
                return image
            }
        } else { // row starts with dark color
            if column % 2 == 0, let image = UIImage(named: Constant.grassDarkIconId) {
                return image
            } else if let image = UIImage(named: Constant.grassLightIconId) {
                return image
            }
        }
        
        return nil
    }
    
    private func setAdjacentBombsCount(_ count: Int) {
        let numberColor = (count > 0 && count < Constant.numberColors.count)
            ? Constant.numberColors[count]
            : Constant.numberColors[0] // transparent
        
        self.adjacentBombsLabel.textColor = numberColor
        self.adjacentBombsLabel.text = String(describing: count)
        self.adjacentBombsLabel.isHidden = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellCover.isHidden = false
        self.cellCover.transform = CGAffineTransform.identity
        
        self.cellFlagIcon.isHidden = true
        self.cellIcon.isHidden = true
        self.adjacentBombsLabel.isHidden = true
        self.adjacentBombsLabel.text = nil
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
