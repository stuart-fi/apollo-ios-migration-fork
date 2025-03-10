#if !COCOAPODS
@_exported import ApolloMigrationAPI
#endif
@_spi(Execution) import ApolloMigration
import Foundation

@dynamicMemberLookup
public class Mock<O: MockObject>: AnyMock, Hashable {

  public var _data: [String: AnyHashable]

  public init() {
    _data = ["__typename": O.objectType.typename]
  }

  public var __typename: String { _data["__typename"] as! String }

  public subscript<T: AnyScalarType & Hashable>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>
  ) -> T? {
    get {
      let field = O._mockFields[keyPath: keyPath]
      return _data[field.key.description] as? T
    }
    set {
      _setScalar(newValue, for: keyPath)
    }
  }

  public func _setScalar<T: AnyScalarType & Hashable>(
    _ value: T?,
    for keyPath: KeyPath<O.MockFields, Field<T>>
  ) {
    let field = O._mockFields[keyPath: keyPath]
    _data[field.key.description] = value
  }

  public subscript<T: MockFieldValue>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>
  ) -> T.MockValueCollectionType.Element? {
    get {
      let field = O._mockFields[keyPath: keyPath]
      return _data[field.key.description] as? T.MockValueCollectionType.Element
    }
    set {
      _setEntity(newValue, for: keyPath)
    }
  }

  public func _setEntity<T: MockFieldValue>(
    _ value: T.MockValueCollectionType.Element?,
    for keyPath: KeyPath<O.MockFields, Field<T>>
  ) {
    let field = O._mockFields[keyPath: keyPath]
    _data[field.key.description] = (value as? AnyHashable)
  }

  public subscript<T: MockFieldValue>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<Array<T>>>
  ) -> [T.MockValueCollectionType.Element]? {
    get {
      let field = O._mockFields[keyPath: keyPath]
      return _data[field.key.description] as? [T.MockValueCollectionType.Element]
    }
    set {
      _setList(newValue, for: keyPath)
    }
  }

  public func _setList<T: MockFieldValue>(
    _ value: [T.MockValueCollectionType.Element]?,
    for keyPath: KeyPath<O.MockFields, Field<Array<T>>>
  ) {
    let field = O._mockFields[keyPath: keyPath]
    _data[field.key.description] = value?._unsafelyConvertToMockValue()
  }

  public subscript<T: AnyScalarType & Hashable>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<Array<T>>>
  ) -> [T]? {
    get {
      let field = O._mockFields[keyPath: keyPath]
      return _data[field.key.description] as? [T]
    }
    set {
      _setScalarList(newValue, for: keyPath)
    }
  }

  public func _setScalarList<T: AnyScalarType & Hashable>(
    _ value: [T]?,
    for keyPath: KeyPath<O.MockFields, Field<Array<T>>>
  ) {
    let field = O._mockFields[keyPath: keyPath]
    _data[field.key.description] = value?._unsafelyConvertToMockValue()
  }

  public var _selectionSetMockData: JSONObject {
    _data.mapValues {
      if let mock = $0.base as? (any AnyMock) {
        return mock._selectionSetMockData
      }
      if let mockArray = $0 as? Array<Any> {
        return mockArray._unsafelyConvertToSelectionSetData()
      }
      return $0
    }
  }

  // MARK: Hashable

  public static func ==(lhs: Mock<O>, rhs: Mock<O>) -> Bool {
    lhs._data == rhs._data    
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_data)
  }
}

// MARK: - Selection Set Conversion

public extension RootSelectionSet {
  static func from<O: MockObject>(
    _ mock: Mock<O>,
    withVariables variables: GraphQLOperation.Variables? = nil
  ) -> Self {
    let accumulator = TestMockSelectionSetMapper<Self>()
    let executor = GraphQLExecutor(executionSource: NetworkResponseExecutionSource())

    return try! executor.execute(
      selectionSet: Self.self,
      on: mock._selectionSetMockData,
      variables: variables,
      accumulator: accumulator
    )
  }
}

// MARK: - Helper Protocols

public protocol AnyMock {
  var _selectionSetMockData: JSONObject { get }
}

public protocol MockObject: MockFieldValue {
  associatedtype MockFields
  associatedtype MockValueCollectionType = Array<Mock<Self>>

  static var objectType: Object { get }
  static var _mockFields: MockFields { get }
}

public protocol MockFieldValue {
  associatedtype MockValueCollectionType: Collection
}

extension Interface: MockFieldValue {
  public typealias MockValueCollectionType = Array<any AnyMock>
}

extension Union: MockFieldValue {
  public typealias MockValueCollectionType = Array<any AnyMock>
}

extension Optional: MockFieldValue where Wrapped: MockFieldValue {
  public typealias MockValueCollectionType = Array<Optional<Wrapped.MockValueCollectionType.Element>>
}

extension Array: MockFieldValue where Array.Element: MockFieldValue {
  public typealias MockValueCollectionType = Array<Element.MockValueCollectionType>
}

fileprivate extension Array {
  func _unsafelyConvertToMockValue() -> [AnyHashable?] {
    map { element in
      switch element {
      case let element as AnyHashable:
        return element

      case let innerArray as Array<Any>:
        return innerArray._unsafelyConvertToMockValue()

      default:
        return nil
      }
    }
  }

  func _unsafelyConvertToSelectionSetData() -> [AnyHashable?] {
    map(_unsafelyConvertToSelectionSetData(element:))
  }

  private func _unsafelyConvertToSelectionSetData(element: Any) -> AnyHashable? {
    switch element {
    case let element as any AnyMock:
      return element._selectionSetMockData

    case let innerArray as Array<Any>:
      return innerArray._unsafelyConvertToSelectionSetData()

    case let element as AnyHashable:
      if DataDict._AnyHashableCanBeCoerced {
        return element

      } else {
        return _unsafelyConvertToSelectionSetData(element: element.base)
      }

    default:
      return nil
    }
  }
}
