import Foundation
import FiApollo
import FiApolloAPI

public final class WebSocketTransport: SubscriptionNetworkTransport {

  public enum Error: Swift.Error {
    /// WebSocketTransport has not yet been implemented for Apollo iOS 2.0. This will be implemented in a future
    /// release.
    case notImplemented
  }

  public func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: FiApollo.FetchBehavior,
    requestConfiguration: FiApollo.RequestConfiguration
  ) throws -> AsyncThrowingStream<FiApollo.GraphQLResponse<Subscription>, any Swift.Error> {
    throw Error.notImplemented
  }

}
