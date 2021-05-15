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
	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> CoreDataCache {
		try find(in: context).map(context.delete)
		return CoreDataCache(context: context)
	}

	static func find(in context: NSManagedObjectContext) throws -> CoreDataCache? {
		let request: NSFetchRequest = fetchRequest()
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}

	var localFeed: [LocalFeedImage] {
		return feed!.compactMap { ($0 as? CoreDataFeedImage)?.local }
	}
}
