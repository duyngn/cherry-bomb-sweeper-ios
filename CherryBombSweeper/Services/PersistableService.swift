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
    }

    static func saveGameOptionsToUserDefaults(_ gameOptions: GameOptions) {
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: gameOptions)
        
        userDefaults.set(encodedData, forKey: Constants.gameOptionsKey)
        userDefaults.synchronize()
    }
    
    static func getGameOptionsFromUserDefaults() -> GameOptions {
        let userDefaults = UserDefaults.standard
        if let decoded  = userDefaults.object(forKey: Constants.gameOptionsKey) as? Data,
            let decodedGameOptions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? GameOptions {
            
            return decodedGameOptions
        }
        
        return GameOptions()
    }
}
