//
//  PersistableService.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/25/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

class PersistableService {
    enum Constants {
        static let gameOptionsKey = "gameOptions"
        static let audioOptionsKey = "audioOptions"
    }
    
    static func saveAudioOptions(to userDefaults: UserDefaults = UserDefaults.standard, audioOptions: AudioOptions) {
        if let encodedData = try? JSONEncoder().encode(audioOptions) {
            userDefaults.set(encodedData, forKey: Constants.audioOptionsKey)
            userDefaults.synchronize()
        }
    }
    
    static func getAudioOptions(from userDefaults: UserDefaults = UserDefaults.standard) -> AudioOptions {
        if let decoded  = userDefaults.object(forKey: Constants.audioOptionsKey) as? Data,
            let audioOptions = try? JSONDecoder().decode(AudioOptions.self, from: decoded) {
            return audioOptions
        }

        return AudioOptions()
    }

    static func saveGameOptions(to userDefaults: UserDefaults = UserDefaults.standard, gameOptions: GameOptions) {
        if let encodedData = try? JSONEncoder().encode(gameOptions) {
            userDefaults.set(encodedData, forKey: Constants.gameOptionsKey)
            userDefaults.synchronize()
        }
    }
    
    static func getGameOptions(from userDefaults: UserDefaults = UserDefaults.standard) -> GameOptions {
        if let decoded  = userDefaults.object(forKey: Constants.gameOptionsKey) as? Data,
            let gameOptions = try? JSONDecoder().decode(GameOptions.self, from: decoded) {
            return gameOptions
        }
        
        return GameOptions()
    }
}
