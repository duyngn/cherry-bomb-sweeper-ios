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
    }
    
    func reinitCell(at index: Int, fieldRows: Int) {
        if let image = self.getCellCoverDarkGrass(row: index / fieldRows, column: index % fieldRows) {
            self.cellCover.image = image
        }
    }
    
    func setupCellView(with cell: Cell) {
    
        switch cell.state {
        case .untouched:
            if let grassImage = self.getCellCoverGrass(at: cell.fieldCoord) {
                self.cellCover.image = grassImage
            }
            self.cellCover.isHidden = false
        case .revealed:
            if cell.adjacentBombs > 0 {
                self.setAdjacentBombsCount(cell.adjacentBombs)
            }
            
            self.cellCover.isHidden = true
        case .flagged:
            self.cellFlagIcon.isHidden = false
            
            if let flagImage = self.getCellCoverGrass(at: cell.fieldCoord) {
                self.cellCover.image = flagImage
            }
        case .exploded:
            if let boomImage = GameGeneralService.shared.boomImage {
                self.cellCover.image = boomImage
                self.cellCover.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
        case .highlight:
            self.cellCover.isHidden = true
        case .showBomb:
            self.cellCover.isHidden = true
            self.cellIcon.isHidden = false
        case .wrongBomb:
            if let xImage = GameGeneralService.shared.xImage {
                self.cellCover.image = xImage
                self.cellCover.isHidden = false
            } else {
                self.cellCover.isHidden = true
            }
            
            self.cellIcon.isHidden = false
        }
    }
    
    private func getCellCoverDarkGrass(row: Int, column: Int) -> UIImage? {
        guard let darkGrassImage = GameGeneralService.shared.darkGrassImage else { return nil }
        
        if row % 2 == 0 { // row starts with light color
            if column % 2 != 0 {
                return darkGrassImage
            }
        } else if column % 2 == 0 {
            return darkGrassImage
        }
        
        return nil
    }
    
    private func getCellCoverGrass(at fieldCoord: FieldCoord) -> UIImage? {
        guard let darkGrassImage = GameGeneralService.shared.darkGrassImage,
              let lightGrassImage = GameGeneralService.shared.lightGrassImage else {
            return nil
        }
        
        let row = fieldCoord.row
        let column = fieldCoord.column
        
        if row % 2 == 0 { // row starts with light color
            if column % 2 == 0 {
                return lightGrassImage
            } else {
                return darkGrassImage
            }
        } else { // row starts with dark color
            if column % 2 == 0 {
                return darkGrassImage
            } else {
                return lightGrassImage
            }
        }
    }
    
    private func setAdjacentBombsCount(_ count: Int) {
        let numberColor = (count > 0 && count < Constant.numberColors.count)
            ? Constant.numberColors[count]
            : Constant.numberColors[0] // transparent
        
        self.adjacentBombsLabel.textColor = numberColor
        self.adjacentBombsLabel.text = String(describing: count)
        self.adjacentBombsLabel.isHidden = false
    }
    
    private func resetCell() {
        self.cellCover.isHidden = false
        self.cellCover.transform = CGAffineTransform.identity
        if let lightGrassImage = GameGeneralService.shared.lightGrassImage {
            self.cellCover.image = lightGrassImage
        }
        
        self.cellFlagIcon.isHidden = true
        self.cellIcon.isHidden = true
        self.adjacentBombsLabel.isHidden = true
        self.adjacentBombsLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetCell()
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
