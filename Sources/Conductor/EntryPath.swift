public struct EntryPath<Entry>: CustomStringConvertible, Sequence where Entry : NavigableEntry {
    public typealias Element = Entry
    public typealias Iterator = Array<Entry>.Iterator
    
    internal var entries: [Entry]
    
    public var isEmpty: Bool { entries.isEmpty }
    
    public var count: Int { entries.count }
    
    public var description: String {
        let str = entries.map { $0.description }.joined(separator: " -> ")
        return str.isEmpty ? "<empty>" : str
    }
    
    init() {
        self.entries = []
    }
    
    init<S>(_ entries: S) where S : Sequence, S.Element == Entry {
        self.entries = Array(entries)
    }
    
    func firstIndex(type: String) -> Array.Index? {
        return entries.firstIndex(where: { it in it.type == type })
    }
    
    func lastIndex(type: String) -> Array.Index? {
        return entries.lastIndex(where: { it in it.type == type })
    }
    
    var first: Entry? {
        return entries.first
    }
    
    func dropFirst() -> EntryPath<Entry> {
        return EntryPath(entries.dropFirst())
    }
    
    @discardableResult
    mutating func popFirst() -> Entry? {
        if let first = entries.first {
            entries.removeFirst()
            return first
        } else {
            return nil
        }
    }
    
    @discardableResult
    mutating func popLast() -> Entry? {
        return entries.popLast()
    }
    
    @discardableResult
    mutating func popLast(id: String) -> Entry? {
        if let last = entries.last, last.id == id {
            entries.removeLast()
            return last
        } else {
            return nil
        }
    }
    
    mutating func removeLast(_ k: Int = 1) {
        entries.removeLast(k)
    }
    
    mutating func append(_ entry: Entry) {
        entries.append(entry)
    }
    
    mutating func clear() {
        entries.removeAll()
    }
    
    public func makeIterator() -> Array<Entry>.Iterator {
        return entries.makeIterator()
    }
}
