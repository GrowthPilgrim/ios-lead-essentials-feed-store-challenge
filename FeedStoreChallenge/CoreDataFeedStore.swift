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
			var cache: CoreDataCache?
			do {
				cache = try self.context.fetch(CoreDataCache.fetchRequest()).first as? CoreDataCache
			} catch {
				return completion(.failure(error))
			}

			guard let cache = cache, let timestamp = cache.timestamp else {
				return completion(.empty)
			}

			completion(.found(feed: cache.localFeed(), timestamp: timestamp))
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform { [unowned self] in
			deleteCachedFeed { _ in
				do {
					try CoreDataCache(context: self.context).save(feed, timestamp: timestamp)
					completion(.none)
				} catch {
					context.rollback()
					completion(error)
				}
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		context.perform { [unowned self] in
			do {
				let existingCaches = try self.context.fetch(CoreDataCache.fetchRequest()) as? [CoreDataCache]
				existingCaches?.forEach { self.context.delete($0) }
				completion(.none)
			} catch {
				completion(error)
			}
		}
	}
}
