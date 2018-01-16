//
//  OptionsViewController.swift
//  C4Sweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
    enum Constant {
        static let minDimension: Int = 9
        static let maxDimension: Int = 30
        static let minMines: Int = 10
        static let maxMines: Int = 300
        
        static let dimensionRange: [Int] = Array(Constant.minDimension...Constant.maxDimension)
        static let mineRange: [Int] = Array(Constant.minMines...Constant.maxMines)
    }

    @IBOutlet private weak var gridSizeLabel: UILabel!
    @IBOutlet private weak var minesCountLabel: UILabel!
    
    @IBOutlet private weak var rowCountPicker: UIPickerView!
    @IBOutlet private weak var columnCountPicker: UIPickerView!
    @IBOutlet private weak var mineCountPicker: UIPickerView!
    
    private var gameOptions: GameOptions = GameServices.shared.gameOptions

    fileprivate var selectedRowIndex: Int = 0
    fileprivate var selectedColumnIndex: Int = 0
    fileprivate var selectedMinesIndex: Int = 0
    
    fileprivate lazy var initialize: Void = {
        self.updateGameConfigLabels()
        self.updateSelectedPickerIndices()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Options"
        // Do any additional setup after loading the view.
        
        rowCountPicker.delegate = self
        rowCountPicker.dataSource = self
        
        columnCountPicker.delegate = self
        columnCountPicker.dataSource = self
        
        mineCountPicker.delegate = self
        mineCountPicker.dataSource = self
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
        let currentRow = self.gameOptions.rowCount - Constant.minDimension
        let currentCol = self.gameOptions.columnCount - Constant.minDimension
        let currentMines = self.gameOptions.minesCount - Constant.minMines
        
        self.selectedRowIndex = (currentRow >= 0) ? currentRow : 0
        self.selectedColumnIndex = (currentCol >= 0) ? currentCol : 0
        self.selectedMinesIndex = (currentMines >= 0) ? currentMines: 0
        
        self.rowCountPicker.selectRow(self.selectedRowIndex, inComponent: 0, animated: false)
        self.columnCountPicker.selectRow(self.selectedColumnIndex, inComponent: 0, animated: false)
        self.mineCountPicker.selectRow(self.selectedMinesIndex, inComponent: 0, animated: false)
    }
    
    private func updateGameConfigLabels() {
        self.gridSizeLabel.text = "\(self.gameOptions.rowCount) x \(self.gameOptions.columnCount)"
        self.minesCountLabel.text = "\(self.gameOptions.minesCount) Mines"
    }
    
    @IBAction func onEasyButtonPressed(_ sender: UIButton) {
        // 9x9, 10 mines
        self.saveConfig(row: 9, col: 9, mines: 10)
        self.updateGameConfigLabels()
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onIntermediateButtonPressed(_ sender: UIButton) {
        // 16x16, 40 mines
        self.saveConfig(row: 16, col: 16, mines: 40)
        self.updateGameConfigLabels()
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onExpertButtonPressed(_ sender: UIButton) {
        // 24x24, 99 mines
        self.saveConfig(row: 24, col: 24, mines: 99)
        self.updateGameConfigLabels()
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onSaveButtonPressed(_ sender: UIButton) {
        let rowCount = Constant.dimensionRange[selectedRowIndex]
        let columnCount = Constant.dimensionRange[selectedColumnIndex]
        let minesCount = Constant.mineRange[selectedMinesIndex]
        
        if let errorMessage = validateConfig(rowCount: rowCount, columnCount: columnCount, minesCount: minesCount) {
            self.showToast(message: errorMessage)
        } else {
            self.saveConfig(row: rowCount, col: columnCount, mines: minesCount)
            self.navigationController?.popViewController(animated: true)
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
        GameServices.shared.gameOptions.rowCount = row
        GameServices.shared.gameOptions.columnCount = col
        GameServices.shared.gameOptions.minesCount = mines
    }
}

extension OptionsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0, 1:
            return String(describing: Constant.dimensionRange[row])
        case 2:
            return String(describing: Constant.mineRange[row])
        default:
            return "-"
        }
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
