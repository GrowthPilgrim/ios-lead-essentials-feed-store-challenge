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
public class CoreDataFeedImage: NSManagedObject {
	convenience init(context: NSManagedObjectContext, from image: LocalFeedImage) {
		self.init(context: context)

		self.id = image.id
		self.imageDescription = image.description
		self.location = image.location
		self.url = image.url
	}
}
