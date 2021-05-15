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
			do {
				let cache = try CoreDataCache.fetch(on: context)
				guard let cache = cache else {
					return completion(.empty)
				}
				completion(.found(feed: cache.feed, timestamp: cache.timestamp))
			} catch {
				return completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.performAndWait { [unowned self] in
			deleteCachedFeed { error in
				guard error == nil else {
					context.rollback()
					return completion(error)
				}

				do {
					try CoreDataCache(context: context, feed: feed, timestamp: timestamp)?.save()
					completion(.none)
				} catch {
					context.rollback()
					completion(error)
				}
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		context.performAndWait { [unowned self] in
			do {
				try CoreDataCache.delete(on: context)
				completion(.none)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}
}
