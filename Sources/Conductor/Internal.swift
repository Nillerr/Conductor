public typealias TypeId = String

internal func toTypeIdentifier<Value>(_ type: Value.Type) -> TypeId {
    return String(reflecting: type)
}
