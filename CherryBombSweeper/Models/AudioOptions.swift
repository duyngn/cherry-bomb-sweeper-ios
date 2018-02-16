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

struct AudioOptions: Codable {
    var isMusicEnabled: Bool = true
    var isSoundEffectsEnabled: Bool = true
    
    init(musicEnabled: Bool = true, sfxEnabled: Bool = true) {
        self.isMusicEnabled = musicEnabled
        self.isSoundEffectsEnabled = sfxEnabled
    }
}
