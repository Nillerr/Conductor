public struct NavigationPath: CustomStringConvertible {
    var entries: [NavigationEntry]
    
    var isEmpty: Bool { entries.isEmpty }
    
    public var description: String {
        let str = entries.map { $0.description }.joined(separator: " -> ")
        return str.isEmpty ? "<empty>" : str
    }
    
    init() {
        self.entries = []
    }
    
    init<S>(_ entries: S) where S : Sequence, S.Element == NavigationEntry {
        self.entries = Array(entries)
    }
    
    func firstIndex(type: String) -> Array.Index? {
        return entries.firstIndex(where: { it in it.type == type })
    }
    
    func lastIndex(type: String) -> Array.Index? {
        return entries.lastIndex(where: { it in it.type == type })
    }
    
    @discardableResult
    mutating func popFirst() -> NavigationEntry? {
        if let first = entries.first {
            entries.removeFirst()
            return first
        } else {
            return nil
        }
    }
    
    @discardableResult
    mutating func popLast() -> NavigationEntry? {
        return entries.popLast()
    }
    
    @discardableResult
    mutating func popLast(id: String) -> NavigationEntry? {
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
    
    mutating func append(_ entry: NavigationEntry) {
        entries.append(entry)
    }
    
    mutating func clear() {
        entries.removeAll()
    }
}
