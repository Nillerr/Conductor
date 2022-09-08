public struct NavigationEntry: CustomStringConvertible {
    public let id: String
    public let type: String
    public let value: AnyHashable
    
    public var description: String {
        return "\(type)<\(id)>"
    }
}
