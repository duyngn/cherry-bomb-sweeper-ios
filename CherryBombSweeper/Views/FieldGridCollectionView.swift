//
//  FieldGridCollectionView.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/15/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

typealias FieldSetupCompletionHandler = (_ fieldWidth: CGFloat, _ fieldHeight: CGFloat) -> Void

class FieldGridCollectionView: UICollectionView {
    
    enum Constant {
        static let gridCellIdentifier = "FieldGridCell"
    }
    
    var cellTapHandler: CellTapHandler?
    
    fileprivate var rowCount: Int = 0
    fileprivate var columnCount: Int = 0
    fileprivate var cellDimension: CGFloat = GameGeneralService.Constant.defaultCellDimension
    
    private var dimensionConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        if let layout = layout as? FieldGridCollectionViewLayout {
            layout.delegate = self
        }
        
        self.delegate = self
        
        self.register(UINib(nibName: Constant.gridCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Constant.gridCellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupFieldGrid(rows: Int, columns: Int,
                        dataSource: UICollectionViewDataSource,
                        cellTapHandler: @escaping CellTapHandler,
                        completionHandler: FieldSetupCompletionHandler?) {
        self.dataSource = dataSource
        self.cellTapHandler = cellTapHandler
        
        self.rowCount = rows
        self.columnCount = columns
        
        let fieldWidth = (CGFloat(self.columnCount) *
            (self.cellDimension + GameGeneralService.Constant.cellSpacing)) - GameGeneralService.Constant.cellSpacing
        let fieldHeight = (CGFloat(self.rowCount) *
            (self.cellDimension + GameGeneralService.Constant.cellSpacing)) - GameGeneralService.Constant.cellSpacing
        
        self.isScrollEnabled = false
        
        self.translatesAutoresizingMaskIntoConstraints = false
        if !self.dimensionConstraints.isEmpty {
            self.removeConstraints(dimensionConstraints)
            self.dimensionConstraints.removeAll()
        }
        
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: fieldWidth)
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: fieldHeight)
        
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        
        self.dimensionConstraints = [widthConstraint, heightConstraint]
        
        completionHandler?(fieldWidth, fieldHeight)
    }
}

extension FieldGridCollectionView: FieldGridLayoutDelegate {    
    func collectionView(rowCountForFieldGrid collectionView: UICollectionView) -> Int {
        return self.rowCount
    }
    
    func collectionView(columnCountForFieldGrid collectionView: UICollectionView) -> Int {
        return self.columnCount
    }
    
    func collectionView(cellDimensionForFieldGrid collectionView: UICollectionView) -> CGFloat {
        return self.cellDimension
    }
    
    func collectionView(cellSpacingForFieldGrid collectionView: UICollectionView) -> CGFloat {
        return GameGeneralService.Constant.cellSpacing
    }
    
    func collectionView(viewWindowForFieldGrid collectionView: UICollectionView) -> CGRect? {
        return self.superview?.frame
    }
}

extension FieldGridCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath) {
        self.cellTapHandler?(didSelectItemAt.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellDimension, height: self.cellDimension);
    }
}
