public protocol NavigableEntry: CustomStringConvertible {
    var id: String { get }
    var type: String { get }
}

extension NavigableEntry {
    public var description: String {
        return "\(type)<\(id)>"
    }
}
