import Foundation
#if !COCOAPODS
import ApolloMigrationAPI
#endif

/// The `ApolloClientProtocol` provides the core API for Apollo. This API provides methods to fetch and watch queries, and to perform mutations.
public protocol ApolloClientProtocol: AnyObject {

  ///  A store used as a local cache.
  var store: ApolloStore { get }

  /// Clears the underlying cache.
  /// Be aware: In more complex setups, the same underlying cache can be used across multiple instances, so if you call this on one instance, it'll clear that cache across all instances which share that cache.
  ///
  /// - Parameters:
  ///   - callbackQueue: The queue to fall back on. Should default to the main queue.
  ///   - completion: [optional] A completion closure to execute when clearing has completed. Should default to nil.
  func clearCache(callbackQueue: DispatchQueue, completion: ((Result<Void, any Error>) -> Void)?)

  /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress fetch.
  func fetch<Query: GraphQLQuery>(query: Query,
                                  cachePolicy: CachePolicy,
                                  contextIdentifier: UUID?,
                                  context: (any RequestContext)?,
                                  queue: DispatchQueue,
                                  resultHandler: GraphQLResultHandler<Query.Data>?) -> (any Cancellable)

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - callbackQueue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  func watch<Query: GraphQLQuery>(query: Query,
                                  cachePolicy: CachePolicy,
                                  context: (any RequestContext)?,
                                  callbackQueue: DispatchQueue,
                                  resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query>

  /// Performs a mutation by sending it to the server.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - publishResultToStore: If `true`, this will publish the result returned from the operation to the cache store. Default is `true`.
  ///   - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress mutation.
  func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                          publishResultToStore: Bool,
                                          contextIdentifier: UUID?,
                                          context: (any RequestContext)?,
                                          queue: DispatchQueue,
                                          resultHandler: GraphQLResultHandler<Mutation.Data>?) -> (any Cancellable)

  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - completionHandler: The completion handler to execute when the request completes or errors. Note that an error will be returned If your `networkTransport` does not also conform to `UploadingNetworkTransport`.
  /// - Returns: An object that can be used to cancel an in progress request.
  func upload<Operation: GraphQLOperation>(operation: Operation,
                                           files: [GraphQLFile],
                                           context: (any RequestContext)?,
                                           queue: DispatchQueue,
                                           resultHandler: GraphQLResultHandler<Operation.Data>?) -> (any Cancellable)

  /// Subscribe to a subscription
  ///
  /// - Parameters:
  ///   - subscription: The subscription to subscribe to.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress subscription.
  func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                    context: (any RequestContext)?,
                                                    queue: DispatchQueue,
                                                    resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> any Cancellable
}

// MARK: - Backwards Compatibilty Extension

public extension ApolloClientProtocol {

  /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress fetch.
  func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy,
    context: (any RequestContext)?,
    queue: DispatchQueue,
    resultHandler: GraphQLResultHandler<Query.Data>?
  ) -> (any Cancellable) {
    self.fetch(
      query: query,
      cachePolicy: cachePolicy,
      contextIdentifier: nil,
      context: context,
      queue: queue,
      resultHandler: resultHandler
    )
  }

  /// Performs a mutation by sending it to the server.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - publishResultToStore: If `true`, this will publish the result returned from the operation to the cache store. Default is `true`.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress mutation.
  func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    publishResultToStore: Bool,
    context: (any RequestContext)?,
    queue: DispatchQueue,
    resultHandler: GraphQLResultHandler<Mutation.Data>?
  ) -> (any Cancellable) {
    self.perform(
      mutation: mutation,
      publishResultToStore: publishResultToStore,
      contextIdentifier: nil,
      context: context,
      queue: queue,
      resultHandler: resultHandler
    )
  }
}
