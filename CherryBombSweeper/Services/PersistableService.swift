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
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: audioOptions)
        
        userDefaults.set(encodedData, forKey: Constants.audioOptionsKey)
        userDefaults.synchronize()
    }
    
    static func getAudioOptions(from userDefaults: UserDefaults = UserDefaults.standard) -> AudioOptions {
        if let decoded  = userDefaults.object(forKey: Constants.audioOptionsKey) as? Data,
            let decodedAudioOptions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? AudioOptions {
            
            return decodedAudioOptions
        }
        
        return AudioOptions()
    }

    static func saveGameOptions(to userDefaults: UserDefaults = UserDefaults.standard, gameOptions: GameOptions) {
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: gameOptions)
        
        userDefaults.set(encodedData, forKey: Constants.gameOptionsKey)
        userDefaults.synchronize()
    }
    
    static func getGameOptions(from userDefaults: UserDefaults = UserDefaults.standard) -> GameOptions {
        let userDefaults = UserDefaults.standard
        if let decoded  = userDefaults.object(forKey: Constants.gameOptionsKey) as? Data,
            let decodedGameOptions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? GameOptions {
            
            return decodedGameOptions
        }
        
        return GameOptions()
    }
}
