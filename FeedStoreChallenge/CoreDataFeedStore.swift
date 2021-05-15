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
		perform { context in
			do {
				let cache = try CoreDataCache.fetch(on: context)
				if let (feed, timestamp) = cache {
					completion(.found(feed: feed, timestamp: timestamp))
				} else {
					return completion(.empty)
				}
			} catch {
				return completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		performAndWait { context in
			do {
				try CoreDataCache.delete(on: context)
				try CoreDataCache(context: context, feed: feed, timestamp: timestamp)?.save()
				completion(.none)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		performAndWait { context in
			do {
				try CoreDataCache.delete(on: context)
				completion(.none)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}

	private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
		context.perform { [weak self] in
			guard let self = self else { return }
			action(self.context)
		}
	}

	private func performAndWait(action: @escaping (NSManagedObjectContext) -> Void) {
		context.performAndWait { [weak self] in
			guard let self = self else { return }
			action(self.context)
		}
	}
}
