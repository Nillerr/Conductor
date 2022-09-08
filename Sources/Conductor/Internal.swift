internal func toTypeIdentifier<Value>(_ type: Value.Type) -> String {
    return String(reflecting: type)
}
