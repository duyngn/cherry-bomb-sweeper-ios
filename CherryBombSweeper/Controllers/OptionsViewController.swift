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
            Array(Constants.minimumFieldDimension...Constants.maximumFieldDimension)
        static let mineRange: [Int] =
            Array(Constants.minimumMines...Constants.maximumMines)
        
        static let easyDimension: Int = 9
        static let easyMines: Int = 10
        static let intermediateDimension: Int = 16
        static let intermediateMines: Int = 40
        static let expertDimension: Int = 24
        static let expertMines: Int = 99
    }
    
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var optionsContainer: UIView!
    
    @IBOutlet private weak var easyButton: UIButton!
    @IBOutlet private weak var intermediateButton: UIButton!
    @IBOutlet private weak var expertButton: UIButton!
    
    @IBOutlet private weak var musicSwitch: UISwitch!
    @IBOutlet private weak var soundEffectsSwitch: UISwitch!
    @IBOutlet private weak var rowCountPicker: UIPickerView!
    @IBOutlet private weak var columnCountPicker: UIPickerView!
    @IBOutlet private weak var mineCountPicker: UIPickerView!
    
    var exitHandler: ExitOptionsHandler?
    
    private var gameOptions: GameOptions = PersistableService.getGameOptions()
    private var audioOptions: AudioOptions = PersistableService.getAudioOptions()
    
    private var audioService: AudioService = AudioService.shared
    private var selectedDifficultyButton: UIButton?
    
    private lazy var initialize: Void = {
        self.updateDifficultyLabels()
        self.updateSelectedPickerIndices()
        self.updateSwitchStates()
        
        self.setupVersionNumber()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rowCountPicker.delegate = self
        self.rowCountPicker.dataSource = self
        
        self.columnCountPicker.delegate = self
        self.columnCountPicker.dataSource = self
        
        self.mineCountPicker.delegate = self
        self.mineCountPicker.dataSource = self
        
        self.scrollView.contentSize = CGSize(width: self.optionsContainer.frame.width, height: 400)
        
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
    
    private func setupVersionNumber() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            var outputVersion = version
            
            if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                outputVersion += ".\(buildNumber)"
            }
            
            self.versionLabel.text = outputVersion
        } else {
            self.versionLabel.isHidden = true
        }
    }
    
    private func updateDifficultyLabels() {
        let validDimensions = [Constant.easyDimension, Constant.intermediateDimension, Constant.expertDimension]
        
        guard validDimensions.contains(self.gameOptions.rowCount), self.gameOptions.columnCount == self.gameOptions.rowCount else {
            self.selectedDifficultyButton?.setTitleColor(Constants.primaryColor, for: .normal)
            self.selectedDifficultyButton = nil
            return
        }
        
        var newDifficultyButton: UIButton?
        
        // Do we have column and row to be one of 3 known sizes?
        
        if self.gameOptions.rowCount == Constant.easyDimension, self.gameOptions.minesCount == Constant.easyMines {
            if let selectedDifficultyButton = self.selectedDifficultyButton, selectedDifficultyButton === self.easyButton {
                return
            }
            // is easy
            newDifficultyButton = self.easyButton
        } else if self.gameOptions.rowCount == Constant.intermediateDimension, self.gameOptions.minesCount == Constant.intermediateMines {
            if let selectedDifficultyButton = self.selectedDifficultyButton, selectedDifficultyButton !== self.intermediateButton {
                return
            }
            // is intermediate
            newDifficultyButton = self.intermediateButton
        } else if self.gameOptions.rowCount == Constant.expertDimension, self.gameOptions.minesCount == Constant.expertMines {
            if let selectedDifficultyButton = self.selectedDifficultyButton, selectedDifficultyButton !== self.expertButton {
                return
            }
            // is expert
            newDifficultyButton = self.expertButton
        }
        
        self.swapDifficultyLabels(to: newDifficultyButton)
    }
    
    private func swapDifficultyLabels(to newDifficultyButton: UIButton?) {
        guard let newDifficultyButton = newDifficultyButton else {
            self.selectedDifficultyButton?.setTitleColor(Constants.primaryColor, for: .normal)
            self.selectedDifficultyButton = nil
            return
        }
        
        self.selectedDifficultyButton?.setTitleColor(Constants.primaryColor, for: .normal)
        newDifficultyButton.setTitleColor(Constants.accentColor, for: .normal)
        self.selectedDifficultyButton = newDifficultyButton
    }
    
    private func updateSwitchStates() {
        self.musicSwitch.isOn = self.audioOptions.isMusicEnabled
        self.soundEffectsSwitch.isOn = self.audioOptions.isSoundEffectsEnabled
    }
    
    private func updateSelectedPickerIndices() {
        let currentRow = self.gameOptions.rowCount - Constants.minimumFieldDimension
        let currentCol = self.gameOptions.columnCount - Constants.minimumFieldDimension
        let currentMines = self.gameOptions.minesCount - Constants.minimumMines
        
        let selectedRowIndex = (currentRow >= 0) ? currentRow : 0
        let selectedColumnIndex = (currentCol >= 0) ? currentCol : 0
        let selectedMinesIndex = (currentMines >= 0) ? currentMines: 0
        
        self.rowCountPicker.selectRow(selectedRowIndex, inComponent: 0, animated: false)
        self.columnCountPicker.selectRow(selectedColumnIndex, inComponent: 0, animated: false)
        self.mineCountPicker.selectRow(selectedMinesIndex, inComponent: 0, animated: false)
    }
    
    @IBAction func onMusicToggle(_ uiSwitch: UISwitch) {
        self.audioService.playSelectSound()
        
        self.audioOptions.isMusicEnabled = uiSwitch.isOn
        PersistableService.saveAudioOptions(audioOptions: self.audioOptions)
        
        if !uiSwitch.isOn {
            self.audioService.stopBackgroundMusic()
        }
        
        self.audioService.updateSoundOptions()
    }
    
    @IBAction func onSoundEffectsToggle(_ uiSwitch: UISwitch) {
        self.audioService.playSelectSound(forced: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.audioOptions.isSoundEffectsEnabled = uiSwitch.isOn
            PersistableService.saveAudioOptions(audioOptions: self.audioOptions)
            
            self.audioService.updateSoundOptions()
        }
    }
    
    @IBAction func onEasyButtonPressed(_ button: UIButton) {
        self.audioService.playSelectSound()
        // 9x9, 10 mines
        self.gameOptions.rowCount = Constant.easyDimension
        self.gameOptions.columnCount = Constant.easyDimension
        self.gameOptions.minesCount = Constant.easyMines
        
        self.swapDifficultyLabels(to: button)
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onIntermediateButtonPressed(_ button: UIButton) {
        self.audioService.playSelectSound()
        // 16x16, 40 mines
        self.gameOptions.rowCount = Constant.intermediateDimension
        self.gameOptions.columnCount = Constant.intermediateDimension
        self.gameOptions.minesCount = Constant.intermediateMines
        
        self.swapDifficultyLabels(to: button)
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onExpertButtonPressed(_ button: UIButton) {
        self.audioService.playSelectSound()
        // 24x24, 99 mines
        self.gameOptions.rowCount = Constant.expertDimension
        self.gameOptions.columnCount = Constant.expertDimension
        self.gameOptions.minesCount = Constant.expertMines
        
        self.swapDifficultyLabels(to: button)
        self.updateSelectedPickerIndices()
    }
    
    @IBAction func onCancelButtonPressed(_ button: UIButton) {
        self.audioService.playRevealSound()
        self.exitHandler?(false)
        self.dismiss(animated: true)
    }
    
    @IBAction func onSaveButtonPressed(_ button: UIButton) {
        if let errorMessage = validateConfig(
            rowCount: self.gameOptions.rowCount,
            columnCount: self.gameOptions.columnCount,
            minesCount: self.gameOptions.minesCount) {
            
            self.audioService.playBeepBeepSound()
            self.showToast(message: errorMessage)
        } else {
            self.audioService.playSaveConfigSound()
            self.saveGameConfig()
            self.exitHandler?(true)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onHighScoresButtonPressed(_ sender: UIButton) {
        self.audioService.playSelectSound()
        
        let highScoresController = HighScoreViewController(nibName: "HighScoreViewController", bundle: nil)
        highScoresController.modalPresentationStyle = .overFullScreen
        
        self.present(highScoresController, animated: true)
    }
    
    @IBAction func onCreditButtonPressed(_ sender: UIButton) {
        self.audioService.playSelectSound()
        
        let creditsController = CreditsViewController(nibName: "CreditsViewController", bundle: nil)
        creditsController.modalPresentationStyle = .overFullScreen
        
        self.present(creditsController, animated: true)
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
        toastLabel.textColor = Constants.accentColor
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: Constants.digital7MonoFont, size: 12.0)
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
    
    private func saveGameConfig() {
        // Write to UserDefaults
        PersistableService.saveGameOptions(gameOptions: self.gameOptions)
    }
}

extension OptionsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var valueStr = "-"

        switch pickerView.tag {
        case 0, 1:
            valueStr = String(describing: Constant.dimensionRange[row])
        case 2:
            valueStr = String(describing: Constant.mineRange[row])
        default:
            break
        }
        
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.white
        pickerLabel.text = valueStr
        pickerLabel.font = UIFont(name: Constants.digital7MonoFont, size: 25)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            self.gameOptions.rowCount = Constant.dimensionRange[row]
        case 1:
            self.gameOptions.columnCount = Constant.dimensionRange[row]
        case 2:
            self.gameOptions.minesCount = Constant.mineRange[row]
        default:
            break
        }
        
        self.updateDifficultyLabels()
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
