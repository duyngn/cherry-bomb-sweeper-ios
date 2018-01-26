//
//  OptionsViewController.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

typealias ExitOptionsHandler = (_ newGame: Bool) -> Void

class OptionsViewController: UIViewController {
    enum Constant {
        static let dimensionRange: [Int] =
            Array(GameGeneralService.Constant.minimumFieldDimension...GameGeneralService.Constant.maximumFieldDimension)
        static let mineRange: [Int] =
            Array(GameGeneralService.Constant.minimumMines...GameGeneralService.Constant.maximumMines)
    }
    
    @IBOutlet private weak var rowCountPicker: UIPickerView!
    @IBOutlet private weak var columnCountPicker: UIPickerView!
    @IBOutlet private weak var mineCountPicker: UIPickerView!
    
    var exitHandler: ExitOptionsHandler?
    
    fileprivate var selectedRowIndex: Int = 0
    fileprivate var selectedColumnIndex: Int = 0
    fileprivate var selectedMinesIndex: Int = 0
    
    private var gameOptions: GameOptions = PersistableService.getGameOptionsFromUserDefaults()
    
    fileprivate lazy var initialize: Void = {
        self.updateSelectedPickerIndices()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rowCountPicker.delegate = self
        rowCountPicker.dataSource = self
        
        columnCountPicker.delegate = self
        columnCountPicker.dataSource = self
        
        mineCountPicker.delegate = self
        mineCountPicker.dataSource = self
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.insertSubview(blurEffectView, at: 0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let _ = initialize
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateSelectedPickerIndices() {
        let currentRow = self.gameOptions.rowCount - GameGeneralService.Constant.minimumFieldDimension
        let currentCol = self.gameOptions.columnCount - GameGeneralService.Constant.minimumFieldDimension
        let currentMines = self.gameOptions.minesCount - GameGeneralService.Constant.minimumMines
        
        self.selectedRowIndex = (currentRow >= 0) ? currentRow : 0
        self.selectedColumnIndex = (currentCol >= 0) ? currentCol : 0
        self.selectedMinesIndex = (currentMines >= 0) ? currentMines: 0
        
        self.rowCountPicker.selectRow(self.selectedRowIndex, inComponent: 0, animated: false)
        self.columnCountPicker.selectRow(self.selectedColumnIndex, inComponent: 0, animated: false)
        self.mineCountPicker.selectRow(self.selectedMinesIndex, inComponent: 0, animated: false)
    }
    
    @IBAction func onEasyButtonPressed(_ sender: UIButton) {
        // 9x9, 10 mines
        self.gameOptions.rowCount = 9
        self.gameOptions.columnCount = 9
        self.gameOptions.minesCount = 10
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onIntermediateButtonPressed(_ sender: UIButton) {
        // 16x16, 40 mines
        self.gameOptions.rowCount = 16
        self.gameOptions.columnCount = 16
        self.gameOptions.minesCount = 40
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onExpertButtonPressed(_ sender: UIButton) {
        // 24x24, 99 mines
        self.gameOptions.rowCount = 24
        self.gameOptions.columnCount = 24
        self.gameOptions.minesCount = 99
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onCancelButtonPressed(_ sender: UIButton) {
        self.exitHandler?(false)
        self.dismiss(animated: true)
    }
    
    @IBAction func onSaveButtonPressed(_ sender: UIButton) {
        let rowCount = Constant.dimensionRange[selectedRowIndex]
        let columnCount = Constant.dimensionRange[selectedColumnIndex]
        let minesCount = Constant.mineRange[selectedMinesIndex]
        
        if let errorMessage = validateConfig(rowCount: rowCount, columnCount: columnCount, minesCount: minesCount) {
            self.showToast(message: errorMessage)
        } else {
            self.saveConfig(row: rowCount, col: columnCount, mines: minesCount)
            self.exitHandler?(true)
            self.dismiss(animated: true)
        }
    }
    
    private func validateConfig(rowCount: Int, columnCount: Int, minesCount: Int) -> String? {
        let maxMines = (rowCount-1) * (columnCount-1)
        
        if minesCount > maxMines {
            return "Mines count cannot exceed grid size"
        }
        
        return nil
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: 8, y: self.view.frame.size.height-100, width: self.view.frame.size.width - 16, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    private func saveConfig(row: Int, col: Int, mines: Int) {
        // Write to UserDefaults
        self.gameOptions.rowCount = row
        self.gameOptions.columnCount = col
        self.gameOptions.minesCount = mines
        
        PersistableService.saveGameOptionsToUserDefaults(self.gameOptions)
    }
}

extension OptionsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var valueStr = "-"
        
        switch pickerView.tag {
        case 0, 1:
            valueStr = String(describing: Constant.dimensionRange[row])
        case 2:
            valueStr = String(describing: Constant.mineRange[row])
        default:
            break
        }
        
        return NSAttributedString(string: valueStr, attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            self.selectedRowIndex = row
        case 1:
            self.selectedColumnIndex = row
        case 2:
            self.selectedMinesIndex = row
        default:
            break
        }
    }
}

extension OptionsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0, 1:
            return Constant.dimensionRange.count
        case 2:
            return Constant.mineRange.count
        default:
            return 0
        }
    }
}
