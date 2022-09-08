public struct PresentationBuilder {
    private let idGenerator: IdGenerator
    
    private(set) var steps: [PresentationStep] = []
    
    public init(idGenerator: IdGenerator) {
        self.idGenerator = idGenerator
    }
    
    public mutating func present<Value>(_ value: Value, style: PresentationStyle = .fullScreenCover) where Value : Hashable {
        steps.append(.present(entry(value, style: style)))
    }
    
    public mutating func dismiss() {
        steps.append(.dismiss)
    }
    
    public mutating func invoke(_ block: @escaping () -> Void) {
        steps.append(.invoke(block))
    }
    
    private func entry<Value>(_ value: Value, style: PresentationStyle = .fullScreenCover) -> PresentationEntry where Value : Hashable {
        let id = idGenerator.nextId()
        let type = toTypeIdentifier(Value.self)
        let value = AnyHashable(value)
        return PresentationEntry(id: id, type: type, value: value, style: style)
    }
}
