@_spi(Internal) import FiApolloAPI

public extension ScalarType {
  static var defaultMockValue: Self {
    try! .init(_jsonValue: "")
  }
}

public extension CustomScalarType {
  static var defaultMockValue: Self {
    try! .init(_jsonValue: "")
  }
}
