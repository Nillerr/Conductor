public struct PresentationBuilder {
    private let idGenerator: IdGenerator
    
    private(set) var steps: [PresentationStep] = []
    
    public init(idGenerator: IdGenerator) {
        self.idGenerator = idGenerator
    }
    
    public mutating func present<Value>(_ value: Value, style: PresentationStyle = .fullScreenCover) {
        let id = idGenerator.nextId()
        let type = toTypeIdentifier(Value.self)
        let entry = PresentationEntry(id: id, type: type, value: value, style: style)
        steps.append(.present(entry))
    }
    
    public mutating func go<Value>(to value: Value, style: PresentationStyle = .fullScreenCover) {
        let id = idGenerator.nextId()
        let type = toTypeIdentifier(Value.self)
        let entry = PresentationEntry(id: id, type: type, value: value, style: style)
        steps.append(.go(entry))
    }
    
    public mutating func replace<Value>(_ value: Value) {
        let id = idGenerator.nextId()
        let type = toTypeIdentifier(Value.self)
        let entry = PresentationEntry(id: id, type: type, value: value, style: .fullScreenCover)
        steps.append(.replace(entry))
    }
    
    public mutating func dismiss() {
        steps.append(.dismiss)
    }
    
    public mutating func invoke(immediate: Bool = false, _ block: @escaping () -> Void) {
        steps.append(.invoke(immediate, block))
    }
}
