//
//  OverallStats+CoreDataProperties.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 2/28/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//
//

import Foundation
import CoreData


extension OverallStats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OverallStats> {
        return NSFetchRequest<OverallStats>(entityName: "OverallStats")
    }

    @NSManaged public var games_played: Int64
    @NSManaged public var games_won: Int64
    @NSManaged public var mines_flagged: Int64

}
