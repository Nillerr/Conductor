public typealias TypeId = String

public func toTypeIdentifier<Value>(_ type: Value.Type) -> TypeId {
    return String(reflecting: type)
}
