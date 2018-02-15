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
        
        static let cellBorderColor: CGColor = UIColor.darkGray.cgColor
        static let cellBorder: CGFloat = 0.5
        static let lightCellBorder: CGFloat = 0.3
    }
    
    @IBOutlet private weak var background: UIView!
    @IBOutlet private weak var cellFlagIcon: UIImageView!
    @IBOutlet private weak var cellCover: UIImageView!
    @IBOutlet private weak var adjacentBombsLabel: UILabel!
    @IBOutlet private weak var bombIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.background.layer.borderWidth = Constant.cellBorder
        self.background.layer.borderColor = Constant.cellBorderColor
        
        self.cellCover.layer.borderWidth = Constant.lightCellBorder
        self.cellCover.layer.borderColor = Constant.cellBorderColor
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
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
            self.background.isHidden = false
            
            if cell.adjacentBombs > 0 {
                self.setAdjacentBombsCount(cell.adjacentBombs)
            }
            
            self.cellCover.isHidden = true
        case .flagged:
            self.cellFlagIcon.isHidden = false
            var transform = self.cellFlagIcon.transform
            transform = transform.translatedBy(x: 5, y: -70)
            transform = transform.scaledBy(x: 2, y: 2)
            self.cellFlagIcon.transform = transform

            if let grassImage = self.getCellCoverGrass(at: cell.fieldCoord) {
                self.cellCover.image = grassImage
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.15) {
                    self.cellFlagIcon.transform = CGAffineTransform.identity
                }
            }
        case .exploded:
            self.background.isHidden = false
            
            if let boomImage = GameIconsService.shared.boomImage {
                self.cellCover.image = boomImage
                self.cellCover.layer.borderWidth = CGFloat(0)
                self.cellCover.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
        case .highlight:
            self.background.isHidden = false
            self.cellCover.isHidden = true
        case .showBomb:
            self.bombIcon.isHidden = false
            
            if let grassImage = self.getCellCoverGrass(at: cell.fieldCoord) {
                self.cellCover.image = grassImage
            }
        case .wrongBomb:
            if let xImage = GameIconsService.shared.xImage {
                self.bombIcon.image = xImage
                self.bombIcon.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.bombIcon.isHidden = false
            } else {
                self.cellCover.isHidden = true
            }
            
            self.cellFlagIcon.isHidden = false
        }
    }
    
    private func getCellCoverDarkGrass(row: Int, column: Int) -> UIImage? {
        guard let darkGrassImage = GameIconsService.shared.darkGrassImage else { return nil }
        
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
        guard let darkGrassImage = GameIconsService.shared.darkGrassImage,
              let lightGrassImage = GameIconsService.shared.lightGrassImage else {
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
        self.background.isHidden = true
        
        self.cellCover.isHidden = false
        self.cellCover.transform = CGAffineTransform.identity
        self.cellCover.layer.borderWidth = Constant.lightCellBorder
        if let lightGrassImage = GameIconsService.shared.lightGrassImage {
            self.cellCover.image = lightGrassImage
        }
        
        self.cellFlagIcon.isHidden = true
        
        self.bombIcon.isHidden = true
        self.bombIcon.transform = CGAffineTransform.identity
        if let bombIcon = GameIconsService.shared.bombImage {
            self.bombIcon.image = bombIcon
        }
        
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
