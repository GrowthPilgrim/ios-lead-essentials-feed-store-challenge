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

// MARK: Generated accessors for feed
extension CoreDataCache {
	@objc(insertObject:inFeedAtIndex:)
	@NSManaged public func insertIntoFeed(_ value: CoreDataFeedImage, at idx: Int)

	@objc(removeObjectFromFeedAtIndex:)
	@NSManaged public func removeFromFeed(at idx: Int)

	@objc(insertFeed:atIndexes:)
	@NSManaged public func insertIntoFeed(_ values: [CoreDataFeedImage], at indexes: NSIndexSet)

	@objc(removeFeedAtIndexes:)
	@NSManaged public func removeFromFeed(at indexes: NSIndexSet)

	@objc(replaceObjectInFeedAtIndex:withObject:)
	@NSManaged public func replaceFeed(at idx: Int, with value: CoreDataFeedImage)

	@objc(replaceFeedAtIndexes:withFeed:)
	@NSManaged public func replaceFeed(at indexes: NSIndexSet, with values: [CoreDataFeedImage])

	@objc(addFeedObject:)
	@NSManaged public func addToFeed(_ value: CoreDataFeedImage)

	@objc(removeFeedObject:)
	@NSManaged public func removeFromFeed(_ value: CoreDataFeedImage)

	@objc(addFeed:)
	@NSManaged public func addToFeed(_ values: NSOrderedSet)

	@objc(removeFeed:)
	@NSManaged public func removeFromFeed(_ values: NSOrderedSet)
}

extension CoreDataCache: Identifiable {}
