public protocol NavigationIdGenerator {
    func nextId() -> String
}

public class IncrementingNavigationIdGenerator : NavigationIdGenerator {
    private var next: Int
    
    public init(start: Int = 1) {
        self.next = start
    }
    
    public func nextId() -> String {
        let id = next
        self.next += 1
        return id.description
    }
}
