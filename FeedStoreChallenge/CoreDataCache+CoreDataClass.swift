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
	func save(_ feed: [LocalFeedImage], timestamp: Date) throws {
		guard let context = self.managedObjectContext else { return }

		let coreDataFeed: [CoreDataFeedImage] = feed.map { localImage in
			let managedImage = CoreDataFeedImage(context: context)
			managedImage.update(from: localImage)
			return managedImage
		}

		addToFeed(NSOrderedSet(array: coreDataFeed))
		self.timestamp = timestamp

		try managedObjectContext?.save()
	}

	func localFeed() -> [LocalFeedImage] {
		coreDataFeed().map {
			LocalFeedImage(id: $0.id!, description: $0.imageDescription, location: $0.location, url: $0.url!)
		}
	}

	private func coreDataFeed() -> [CoreDataFeedImage] {
		return feed?.array as? [CoreDataFeedImage] ?? []
	}
}

extension NSManagedObjectContext {
	func fetchCache() throws -> (feed: [LocalFeedImage], timestamp: Date)? {
		let caches: [CoreDataCache] = try fetch(CoreDataCache.fetchRequest())
		guard let cache = caches.first,
		      let timestamp = caches.first?.timestamp else {
			return nil
		}

		return (cache.localFeed(), timestamp)
	}

	func deleteCache() throws {
		let existingCaches = try fetch(CoreDataCache.fetchRequest()) as? [CoreDataCache]
		existingCaches?.forEach { delete($0) }
		try save()
	}
}
