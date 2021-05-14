//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform { [unowned self] in
			let request: NSFetchRequest<CoreDataCache> = CoreDataCache.fetchRequest()
			if let cache = try? self.context.fetch(request).first,
			   let feed = cache.feed?.array as? [CoreDataFeedImage],
			   let timestamp = cache.timestamp {
				let imageFeed = feed.map {
					return LocalFeedImage(id: $0.id!, description: $0.imageDescription, location: $0.location, url: $0.url!)
				}

				completion(.found(feed: imageFeed, timestamp: timestamp))
			} else {
				completion(.empty)
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform { [unowned self] in

			let coreDataFeed: [CoreDataFeedImage] = feed.map { image in
				let coreDataFeedImage = CoreDataFeedImage(context: self.context)
				coreDataFeedImage.id = image.id
				coreDataFeedImage.imageDescription = image.description
				coreDataFeedImage.location = image.location
				coreDataFeedImage.url = image.url
				return coreDataFeedImage
			}

			do {
				let coreDataCache = CoreDataCache(context: self.context)
				coreDataCache.timestamp = timestamp
				coreDataCache.feed = NSOrderedSet(array: coreDataFeed)
				self.context.insert(coreDataCache)
				try self.context.save()
				completion(.none)
			} catch {
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		fatalError("Must be implemented")
	}
}
