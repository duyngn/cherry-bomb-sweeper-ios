//
//  HighScorePlayer+CoreDataProperties.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 2/28/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//
//

import Foundation
import CoreData


extension HighScorePlayer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HighScorePlayer> {
        return NSFetchRequest<HighScorePlayer>(entityName: "HighScorePlayer")
    }

    @NSManaged public var playerName: String?
    @NSManaged public var gameTime: Int64
    @NSManaged public var difficultyCategory: DifficultyCategory

}
