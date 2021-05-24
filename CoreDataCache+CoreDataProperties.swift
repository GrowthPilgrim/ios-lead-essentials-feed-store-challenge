//
//  CoreDataCache+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Dennis Nehrenheim on 19.05.21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

extension CoreDataCache {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataCache> {
		return NSFetchRequest<CoreDataCache>(entityName: "CoreDataCache")
	}

	@NSManaged public var timestamp: Date
	@NSManaged public var feed: NSOrderedSet
}
