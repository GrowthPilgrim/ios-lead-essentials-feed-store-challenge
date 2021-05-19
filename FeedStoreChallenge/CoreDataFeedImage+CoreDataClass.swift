//
//  CoreDataFeedImage+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by Dennis Nehrenheim on 14.05.21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import CoreData

@objc(CoreDataFeedImage)
final class CoreDataFeedImage: NSManagedObject {
	convenience init(context: NSManagedObjectContext, from image: LocalFeedImage) {
		self.init(context: context)

		self.id = image.id
		self.imageDescription = image.description
		self.location = image.location
		self.url = image.url
	}

	static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		return NSOrderedSet(array: localFeed.map { CoreDataFeedImage(context: context, from: $0) })
	}

	var local: LocalFeedImage {
		LocalFeedImage(id: id!, description: imageDescription, location: location, url: url!)
	}
}
