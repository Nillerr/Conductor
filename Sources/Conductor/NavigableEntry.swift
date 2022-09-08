public protocol NavigableEntry: CustomStringConvertible {
    var id: String { get }
    var type: TypeId { get }
}

extension NavigableEntry {
    public var description: String {
        return "\(type)<\(id)>"
    }
}
