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
    
    private var bkgMusicPlayer: AVAudioPlayer = AVAudioPlayer()
    private var tapSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var probeSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var flagSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var revealSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var explodeSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var winningSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var beepBeepSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var positiveSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var selectSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    private var saveConfigSfxPlayer: AVAudioPlayer = AVAudioPlayer()
    
    private init() {
        self.setupMusicPlayers()
    }
    
    private func setupMusicPlayers() {
        if let bkgMusicFilePath = Bundle.main.path(forResource: "bkg_music_1", ofType: "mp3") {
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
        
        if let tapSfxFilePath = Bundle.main.path(forResource: "tap_sound", ofType: "mp3") {
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
        
        if let revealSfxFilePath = Bundle.main.path(forResource: "reveal_sound", ofType: "mp3") {
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
        
        if let probeSfxFilePath = Bundle.main.path(forResource: "probe_sound", ofType: "wav") {
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
        
        if let flagSfxFilePath = Bundle.main.path(forResource: "flag_sound", ofType: "mp3") {
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
        
        if let explodeSfxPath = Bundle.main.path(forResource: "explosion_sound", ofType: "mp3") {
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
        
        if let winningSfxFilePath = Bundle.main.path(forResource: "winning_music", ofType: "mp3") {
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
        
        if let beepBeepSfxFilePath = Bundle.main.path(forResource: "beep_beep_sound", ofType: "mp3") {
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
        
        if let positiveSfxFilePath = Bundle.main.path(forResource: "positive_sound", ofType: "mp3") {
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
        
        if let selectSfxFilePath = Bundle.main.path(forResource: "select_sound", ofType: "mp3") {
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
        
        if let saveConfigSfxFilePath = Bundle.main.path(forResource: "save_config_sound", ofType: "mp3") {
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
    }
    
    func playTapSound() {
        self.tapSfxPlayer.pause()
        self.tapSfxPlayer.currentTime = 0
        self.tapSfxPlayer.play()
    }
    
    func playProbeSound() {
        self.probeSfxPlayer.pause()
        self.probeSfxPlayer.currentTime = 0
        self.probeSfxPlayer.play()
    }
    
    func playFlagSound() {
        self.flagSfxPlayer.pause()
        self.flagSfxPlayer.currentTime = 0
        self.flagSfxPlayer.play()
    }
    
    func playRevealSound() {
        self.revealSfxPlayer.pause()
        self.revealSfxPlayer.currentTime = 0
        self.revealSfxPlayer.play()
    }
    
    func playExplodeSound() {
        self.explodeSfxPlayer.pause()
        self.explodeSfxPlayer.currentTime = 0
        self.explodeSfxPlayer.play()
    }
    
    func playWinningMusic() {
        self.winningSfxPlayer.play()
    }
    
    func playBeepBeepSound() {
        self.beepBeepSfxPlayer.stop()
        self.beepBeepSfxPlayer.currentTime = 0
        self.beepBeepSfxPlayer.play()
    }
    
    func playPositiveSound() {
        self.positiveSfxPlayer.stop()
        self.positiveSfxPlayer.currentTime = 0
        self.positiveSfxPlayer.play()
    }
    
    func playSelectSound() {
        self.selectSfxPlayer.stop()
        self.selectSfxPlayer.currentTime = 0
        self.selectSfxPlayer.play()
    }
    
    func playSaveConfigSound() {
        self.saveConfigSfxPlayer.stop()
        self.saveConfigSfxPlayer.currentTime = 0
        self.saveConfigSfxPlayer.play()
    }
    
    func startBackgroundMusic() {
        self.bkgMusicPlayer.play()
        self.bkgMusicPlayer.setVolume(0.15, fadeDuration: 3)
    }
    
    func stopBackgroundMusic() {
        self.bkgMusicPlayer.setVolume(0, fadeDuration: 0.3)
        self.bkgMusicPlayer.pause()
    }
}
