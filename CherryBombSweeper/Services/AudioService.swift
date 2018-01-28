//
//  AudioService.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/26/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import AVFoundation

class AudioService {
    
    static let shared = AudioService()
    
    private var bkgMusicPlayer: AVAudioPlayer?
    private var tapSfxPlayer: AVAudioPlayer?
    private var probeSfxPlayer: AVAudioPlayer?
    private var flagSfxPlayer: AVAudioPlayer?
    private var revealSfxPlayer: AVAudioPlayer?
    private var explodeSfxPlayer: AVAudioPlayer?
    private var winningSfxPlayer: AVAudioPlayer?
    private var beepBeepSfxPlayer: AVAudioPlayer?
    private var positiveSfxPlayer: AVAudioPlayer?
    private var selectSfxPlayer: AVAudioPlayer?
    private var saveConfigSfxPlayer: AVAudioPlayer?
    
    private let audioQueue: DispatchQueue = DispatchQueue(label: "gameAudioQueue", qos: .userInitiated)
    
    var isMusicEnabled: Bool = true
    var isSoundEffectsEnabled: Bool = true
    
    private init() {
        self.audioQueue.async {
            self.updateSoundOptions()
        }
    }
    
    func updateSoundOptions() {
        let audioOptions = PersistableService.getAudioOptions()
        self.isMusicEnabled = audioOptions.isMusicEnabled
        self.isSoundEffectsEnabled = audioOptions.isSoundEffectsEnabled
        
        self.setupMusicPlayers()
    }
    
    private func setupMusicPlayers() {
        // Always load this one
        if self.selectSfxPlayer == nil, let selectSfxFilePath = Bundle.main.path(forResource: "select_sound", ofType: "mp3") {
            let selectSfxURL = URL(fileURLWithPath: selectSfxFilePath)
            do {
                let avPlayer = try AVAudioPlayer(contentsOf: selectSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                avPlayer.numberOfLoops = 0
                avPlayer.volume = 0.5 // start at 0 volume
                self.selectSfxPlayer = avPlayer
            } catch {
                // no-op
            }
        }
        
        if self.isMusicEnabled {
            if self.bkgMusicPlayer == nil, let bkgMusicFilePath = Bundle.main.path(forResource: "bkg_music_1", ofType: "mp3") {
                let bkgMusicURL = URL(fileURLWithPath: bkgMusicFilePath)
                do {
                    var avPlayer = AVAudioPlayer()
                    avPlayer = try AVAudioPlayer(contentsOf: bkgMusicURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = -1
                    avPlayer.volume = 0 // start at 0 volume
                    self.bkgMusicPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
        } else {
            self.bkgMusicPlayer = nil
        }
        
        if self.isSoundEffectsEnabled {
            if self.tapSfxPlayer == nil, let tapSfxFilePath = Bundle.main.path(forResource: "tap_sound", ofType: "mp3") {
                let tapSfxURL = URL(fileURLWithPath: tapSfxFilePath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: tapSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 0.5 // start at 0 volume
                    self.tapSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
            
            if self.revealSfxPlayer == nil, let revealSfxFilePath = Bundle.main.path(forResource: "reveal_sound", ofType: "mp3") {
                let revealSfxURL = URL(fileURLWithPath: revealSfxFilePath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: revealSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 0.5 // start at 0 volume
                    self.revealSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
            
            if self.probeSfxPlayer == nil, let probeSfxFilePath = Bundle.main.path(forResource: "probe_sound", ofType: "wav") {
                let probeSfxURL = URL(fileURLWithPath: probeSfxFilePath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: probeSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 0.5 // start at 0 volume
                    self.probeSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
            
            if self.flagSfxPlayer == nil, let flagSfxFilePath = Bundle.main.path(forResource: "flag_sound", ofType: "mp3") {
                let flagSfxURL = URL(fileURLWithPath: flagSfxFilePath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: flagSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 0.8 // start at 0 volume
                    self.flagSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
            
            if self.explodeSfxPlayer == nil, let explodeSfxPath = Bundle.main.path(forResource: "explosion_sound", ofType: "mp3") {
                let explodeSfxURL = URL(fileURLWithPath: explodeSfxPath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: explodeSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 0.80 // start at 0 volume
                    self.explodeSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
            
            if self.winningSfxPlayer == nil, let winningSfxFilePath = Bundle.main.path(forResource: "winning_music", ofType: "mp3") {
                let winSfxURL = URL(fileURLWithPath: winningSfxFilePath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: winSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 0.8 // start at 0 volume
                    self.winningSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
            
            if self.beepBeepSfxPlayer == nil, let beepBeepSfxFilePath = Bundle.main.path(forResource: "beep_beep_sound", ofType: "mp3") {
                let beepBeepSfxURL = URL(fileURLWithPath: beepBeepSfxFilePath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: beepBeepSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 0.5 // start at 0 volume
                    self.beepBeepSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
            
            if self.positiveSfxPlayer == nil, let positiveSfxFilePath = Bundle.main.path(forResource: "positive_sound", ofType: "mp3") {
                let positiveSfxURL = URL(fileURLWithPath: positiveSfxFilePath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: positiveSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 0.5 // start at 0 volume
                    self.positiveSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
            
            if self.saveConfigSfxPlayer == nil, let saveConfigSfxFilePath = Bundle.main.path(forResource: "save_config_sound", ofType: "mp3") {
                let saveConfigSfxURL = URL(fileURLWithPath: saveConfigSfxFilePath)
                do {
                    let avPlayer = try AVAudioPlayer(contentsOf: saveConfigSfxURL) //, fileTypeHint: AVFileTypeMPEGLayer3
                    avPlayer.numberOfLoops = 0
                    avPlayer.volume = 1 // start at 0 volume
                    self.saveConfigSfxPlayer = avPlayer
                } catch {
                    // no-op
                }
            }
        } else {
            self.tapSfxPlayer = nil
            self.probeSfxPlayer = nil
            self.flagSfxPlayer = nil
            self.revealSfxPlayer = nil
            self.explodeSfxPlayer = nil
            self.winningSfxPlayer = nil
            self.beepBeepSfxPlayer = nil
            self.positiveSfxPlayer = nil
//            self.selectSfxPlayer = nil
            self.saveConfigSfxPlayer = nil
            
        }
    }
    
    func playTapSound() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let tapSfxPlayer = self.tapSfxPlayer else { return }
            
            tapSfxPlayer.pause()
            tapSfxPlayer.currentTime = 0
            tapSfxPlayer.play()
        }
    }
    
    func playProbeSound() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let probeSfxPlayer = self.probeSfxPlayer else { return }
            
            probeSfxPlayer.pause()
            probeSfxPlayer.currentTime = 0
            probeSfxPlayer.play()
        }
    }
    
    func playFlagSound() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let flagSfxPlayer = self.flagSfxPlayer else { return }
            
            flagSfxPlayer.pause()
            flagSfxPlayer.currentTime = 0
            flagSfxPlayer.play()
        }
    }
    
    func playRevealSound() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let revealSfxPlayer = self.revealSfxPlayer else { return }
            
            revealSfxPlayer.pause()
            revealSfxPlayer.currentTime = 0
            revealSfxPlayer.play()
        }
    }
    
    func playExplodeSound() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let explodeSfxPlayer = self.explodeSfxPlayer else { return }
            
            explodeSfxPlayer.pause()
            explodeSfxPlayer.currentTime = 0
            explodeSfxPlayer.play()
        }
    }
    
    func playWinningMusic() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let winningSfxPlayer = self.winningSfxPlayer else { return }
            
            winningSfxPlayer.play()
        }
    }
    
    func playBeepBeepSound() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let beepBeepSfxPlayer = self.beepBeepSfxPlayer else { return }
            
            beepBeepSfxPlayer.stop()
            beepBeepSfxPlayer.currentTime = 0
            beepBeepSfxPlayer.play()
        }
    }
    
    func playPositiveSound() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let positiveSfxPlayer = self.positiveSfxPlayer else { return }
            
            positiveSfxPlayer.stop()
            positiveSfxPlayer.currentTime = 0
            positiveSfxPlayer.play()
        }
    }
    
    func playSelectSound(forced: Bool = false) {
        self.audioQueue.async {
            guard (forced || self.isSoundEffectsEnabled), let selectSfxPlayer = self.selectSfxPlayer else { return }
            
            selectSfxPlayer.stop()
            selectSfxPlayer.currentTime = 0
            selectSfxPlayer.play()
        }
    }
    
    func playSaveConfigSound() {
        self.audioQueue.async {
            guard self.isSoundEffectsEnabled, let saveConfigSfxPlayer = self.saveConfigSfxPlayer else { return }
            
            saveConfigSfxPlayer.stop()
            saveConfigSfxPlayer.currentTime = 0
            saveConfigSfxPlayer.play()
        }
    }
    
    func startBackgroundMusic() {
        self.audioQueue.async {
            guard self.isMusicEnabled, let bkgMusicPlayer = self.bkgMusicPlayer else { return }
            
            bkgMusicPlayer.play()
            bkgMusicPlayer.setVolume(0.15, fadeDuration: 3)
        }
    }
    
    func stopBackgroundMusic() {
        self.audioQueue.async {
            guard self.isMusicEnabled, let bkgMusicPlayer = self.bkgMusicPlayer else { return }
            
            bkgMusicPlayer.setVolume(0, fadeDuration: 0.3)
            bkgMusicPlayer.pause()
        }
    }
}
