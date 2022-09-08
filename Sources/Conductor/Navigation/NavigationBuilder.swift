public struct NavigationBuilder {
    private let idGenerator: IdGenerator
    
    private(set) var steps: [NavigationStep] = []
    
    public init(idGenerator: IdGenerator) {
        self.idGenerator = idGenerator
    }
    
    public mutating func push<Value>(_ value: Value) where Value : Hashable {
        steps.append(.push(entry(value)))
    }
    
    public mutating func pop(_ count: Int = 1) {
        steps.append(.pop(count))
    }
    
    public mutating func popToRoot() {
        steps.append(.popToRoot)
    }
    
    public mutating func popToFirst<Value>(_ type: Value.Type) where Value : Hashable {
        let type = toTypeIdentifier(type)
        steps.append(.popToFirst(type))
    }
    
    public mutating func popToLast<Value>(_ type: Value.Type) where Value : Hashable {
        let type = toTypeIdentifier(type)
        steps.append(.popToLast(type))
    }
    
    public mutating func goToFirst<Value>(_ value: Value) where Value : Hashable {
        steps.append(.goToFirst(entry(value)))
    }
    
    public mutating func goToLast<Value>(_ value: Value) where Value : Hashable {
        steps.append(.goToLast(entry(value)))
    }
    
    public mutating func invoke(_ block: @escaping () -> Void) {
        steps.append(.invoke(block))
    }
    
    private func entry<Value>(_ value: Value) -> NavigationEntry where Value : Hashable {
        let id = idGenerator.nextId()
        let type = toTypeIdentifier(Value.self)
        let value = AnyHashable(value)
        return NavigationEntry(id: id, type: type, value: value)
    }
}
