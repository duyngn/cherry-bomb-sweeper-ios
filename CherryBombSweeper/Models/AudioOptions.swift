//
//  AudioOption.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/28/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation
//
//  GameOptions.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/10/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import Foundation

class AudioOptions: NSObject, NSCoding {
    var isMusicEnabled: Bool = true
    var isSoundEffectsEnabled: Bool = true
    
    init(musicEnabled: Bool = true, sfxEnabled: Bool = true) {
        self.isMusicEnabled = musicEnabled
        self.isSoundEffectsEnabled = sfxEnabled
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let isMusicEnabled = aDecoder.decodeBool(forKey: "isMusicEnabled")
        let isSoundEffectsEnabled = aDecoder.decodeBool(forKey: "isSoundEffectsEnabled")
        
        self.init(musicEnabled: isMusicEnabled, sfxEnabled: isSoundEffectsEnabled)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.isMusicEnabled, forKey: "isMusicEnabled")
        aCoder.encode(self.isSoundEffectsEnabled, forKey: "isSoundEffectsEnabled")
    }
}
