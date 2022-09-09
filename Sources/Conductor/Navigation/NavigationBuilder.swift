public struct NavigationBuilder {
    private let idGenerator: IdGenerator
    
    private(set) var steps: [NavigationStep] = []
    
    public init(idGenerator: IdGenerator) {
        self.idGenerator = idGenerator
    }
    
    public mutating func push<Value>(_ value: Value) {
        steps.append(.push(entry(value)))
    }
    
    public mutating func pop(_ count: Int = 1) {
        steps.append(.pop(count))
    }
    
    public mutating func popToRoot() {
        steps.append(.popToRoot)
    }
    
    public mutating func popToFirst<Value>(_ type: Value.Type) {
        let type = toTypeIdentifier(type)
        steps.append(.popToFirst(type))
    }
    
    public mutating func popToLast<Value>(_ type: Value.Type) {
        let type = toTypeIdentifier(type)
        steps.append(.popToLast(type))
    }
    
    public mutating func goToFirst<Value>(_ value: Value) {
        steps.append(.goToFirst(entry(value)))
    }
    
    public mutating func goToLast<Value>(_ value: Value) {
        steps.append(.goToLast(entry(value)))
    }
    
    public mutating func invoke(immediate: Bool = false, _ block: @escaping () -> Void) {
        steps.append(.invoke(immediate, block))
    }
    
    private func entry<Value>(_ value: Value) -> NavigationEntry {
        let id = idGenerator.nextId()
        let type = toTypeIdentifier(Value.self)
        return NavigationEntry(id: id, type: type, value: value)
    }
}
