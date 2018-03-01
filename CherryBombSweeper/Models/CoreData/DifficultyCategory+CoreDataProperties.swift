//
//  DifficultyCategory+CoreDataProperties.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 2/28/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//
//

import Foundation
import CoreData


extension DifficultyCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DifficultyCategory> {
        return NSFetchRequest<DifficultyCategory>(entityName: "DifficultyCategory")
    }

    @NSManaged public var gamesPlayed: Int64
    @NSManaged public var gamesWon: Int64
    @NSManaged public var categoryName: String?
    @NSManaged public var totalWinTime: Int64
    @NSManaged public var topPlayers: Set<HighScorePlayer>

}

// MARK: Generated accessors for topPlayers
extension DifficultyCategory {

    @objc(addTopPlayersObject:)
    @NSManaged public func addToTopPlayers(_ value: HighScorePlayer)

    @objc(removeTopPlayersObject:)
    @NSManaged public func removeFromTopPlayers(_ value: HighScorePlayer)

    @objc(addTopPlayers:)
    @NSManaged public func addToTopPlayers(_ values: NSSet)

    @objc(removeTopPlayers:)
    @NSManaged public func removeFromTopPlayers(_ values: NSSet)

}
