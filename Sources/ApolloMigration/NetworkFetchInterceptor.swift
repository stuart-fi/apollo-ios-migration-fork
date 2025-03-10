import Foundation
#if !COCOAPODS
import ApolloMigrationAPI
#endif

/// An interceptor which actually fetches data from the network.
public class NetworkFetchInterceptor: ApolloInterceptor, Cancellable {
  let client: URLSessionClient
  @Atomic private var currentTask: URLSessionTask?

  public var id: String = UUID().uuidString
  
  /// Designated initializer.
  ///
  /// - Parameter client: The `URLSessionClient` to use to fetch data
  public init(client: URLSessionClient) {
    self.client = client
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: any RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) {
    
    let urlRequest: URLRequest
    do {
      urlRequest = try request.toURLRequest()
    } catch {
      chain.handleErrorAsync(
        error,
        request: request,
        response: response,
        completion: completion
      )
      return
    }
    
    let taskDescription = "\(Operation.operationType) \(Operation.operationName)"
    let task = self.client.sendRequest(urlRequest, taskDescription: taskDescription) { [weak self] result in
      guard let self = self else {
        return
      }
      
      defer {
        if Operation.operationType != .subscription {
          self.$currentTask.mutate { $0 = nil }
        }
      }
      
      guard !chain.isCancelled else {
        return
      }
      
      switch result {
      case .failure(let error):
        chain.handleErrorAsync(
          error,
          request: request,
          response: response,
          completion: completion
        )

      case .success(let (data, httpResponse)):
        let response = HTTPResponse<Operation>(
          response: httpResponse,
          rawData: data,
          parsedResponse: nil
        )

        chain.proceedAsync(
          request: request,
          response: response,
          interceptor: self,
          completion: completion
        )
      }
    }
    
    self.$currentTask.mutate { $0 = task }
  }
  
  public func cancel() {
    guard let task = self.currentTask else {
      return
    }
    
    task.cancel()
  }
}
