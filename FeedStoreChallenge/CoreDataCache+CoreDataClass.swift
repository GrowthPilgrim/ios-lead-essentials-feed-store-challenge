//
//  CoreDataCache+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by Dennis Nehrenheim on 14.05.21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import CoreData

@objc(CoreDataCache)
public class CoreDataCache: NSManagedObject {
	convenience init?(context: NSManagedObjectContext, feed: [LocalFeedImage], timestamp: Date) {
		self.init(context: context)

		self.timestamp = timestamp
		self.addToFeed(context.toCoreDataFeed(feed))
	}

	static func delete(on context: NSManagedObjectContext) throws {
		let existingCaches = try context.fetch(fetchRequest()) as? [CoreDataCache]
		existingCaches?.forEach { context.delete($0) }
		try context.save()
	}

	static func fetch(on context: NSManagedObjectContext) throws -> (feed: [LocalFeedImage], timestamp: Date)? {
		let caches: [CoreDataCache] = try context.fetch(CoreDataCache.fetchRequest())
		guard let cache = caches.first, let timestamp = caches.first?.timestamp else {
			return nil
		}

		let feed = context.toLocalFeed(cache.feed?.array as? [CoreDataFeedImage] ?? [])
		return (feed, timestamp)
	}

	func save() throws {
		try managedObjectContext?.save()
	}

	private func addToFeed(_ feed: [CoreDataFeedImage]) {
		self.addToFeed(NSOrderedSet(array: feed))
	}

	private var feedImages: [CoreDataFeedImage] {
		feed?.array as? [CoreDataFeedImage] ?? []
	}
}

fileprivate extension NSManagedObjectContext {
	func toCoreDataFeed(_ localFeed: [LocalFeedImage]) -> [CoreDataFeedImage] {
		return localFeed.map { CoreDataFeedImage(context: self, from: $0) }
	}

	func toLocalFeed(_ coreDataFeed: [CoreDataFeedImage]) -> [LocalFeedImage] {
		return coreDataFeed.map { LocalFeedImage(id: $0.id!, description: $0.imageDescription, location: $0.location, url: $0.url!) }
	}
}
