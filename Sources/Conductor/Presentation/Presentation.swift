import SwiftUI
import Combine

public enum PresentationStyle {
    case fullScreenCover
    case sheet
}

public struct PresentationEntry: NavigableEntry {
    public let id: String
    public let type: String
    public let value: AnyHashable
    public let style: PresentationStyle
}

public enum PresentationStep {
    case dismiss
    case present(PresentationEntry)
    case goToFirst(PresentationEntry)
    case goToLast(PresentationEntry)
    case invoke(() -> Void)
}

public struct PresentationBuilder {
    private let idGenerator: IdGenerator
    
    private(set) var steps: [PresentationStep] = []
    
    public init(idGenerator: IdGenerator) {
        self.idGenerator = idGenerator
    }
    
    public mutating func present<Value>(_ value: Value, style: PresentationStyle) where Value : Hashable {
        steps.append(.present(entry(value, style: style)))
    }
    
    public mutating func dismiss() {
        steps.append(.dismiss)
    }
    
    public mutating func goToFirst<Value>(_ value: Value, style: PresentationStyle) where Value : Hashable {
        steps.append(.goToFirst(entry(value, style: style)))
    }
    
    public mutating func goToLast<Value>(_ value: Value, style: PresentationStyle) where Value : Hashable {
        steps.append(.goToLast(entry(value, style: style)))
    }
    
    public mutating func invoke(_ block: @escaping () -> Void) {
        steps.append(.invoke(block))
    }
    
    private func entry<Value>(_ value: Value, style: PresentationStyle) -> PresentationEntry where Value : Hashable {
        let id = idGenerator.nextId()
        let type = String(describing: Value.self)
        let value = AnyHashable(value)
        return PresentationEntry(id: id, type: type, value: value, style: style)
    }
}

public class PresentationRouter: ObservableObject {
    public struct Configuration {
        public var operationDelay: DispatchTimeInterval = .milliseconds(650)
        
        public init() {
        }
    }
    
    private let idGenerator: IdGenerator
    private let configuration: Configuration
    
    @Published public internal(set) var path = PresentationPath()
    
    private var workQueue: [DispatchWorkItem] = []
    
    public init(
        idGenerator: IdGenerator = IncrementingNavigationIdGenerator(),
        configuration: Configuration = Configuration()
    ) {
        self.idGenerator = idGenerator
        self.configuration = configuration
    }
    
    public func navigate(_ builder: (inout PresentationBuilder) -> Void) {
        var navBuilder = PresentationBuilder(idGenerator: idGenerator)
        builder(&navBuilder)
        
        let currentWork = workQueue
        workQueue.append(contentsOf: navBuilder.steps.map(createWork(for:)))
        
        if currentWork.isEmpty {
            performNextWork()
        } else {
            // The work will be picked up at the end of the pending work
        }
    }
    
    private func performNextWork() {
        guard let work = workQueue.first else { return }
        
        work.perform()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.operationDelay) { [weak self] in
            self?.workQueue.removeFirst()
            self?.performNextWork()
        }
    }
    
    private func createWork(for step: PresentationStep) -> DispatchWorkItem {
        switch step {
        case .dismiss:
            return DispatchWorkItem { [weak self] in self?.dismiss() }
        case .present(let entry):
            return DispatchWorkItem { [weak self] in self?.present(entry) }
        case .goToFirst(let entry):
            return DispatchWorkItem { [weak self] in self?.goToFirst(entry) }
        case .goToLast(let entry):
            return DispatchWorkItem { [weak self] in self?.goToLast(entry) }
        case .invoke(let block):
            return DispatchWorkItem(block: block)
        }
    }
    
    private func dismiss() {
        Logging.log(.stack, "<PresentationRouter> {DISMISS}")
        path.removeLast()
    }
    
    private func present(_ entry: PresentationEntry) {
        Logging.log(.stack, "<PresentationRouter> {PRESENT}", "\tentry: \(entry)")
        path.append(entry)
    }
    
    private func goToFirst(_ entry: PresentationEntry) {
        Logging.log(.stack, "<PresentationRouter> {GO_TO_FIRST}", "\tentry: \(entry)")
        if let index = path.firstIndex(type: entry.type) {
            path = PresentationPath(path.entries[0..<index] + [entry])
        } else {
            path.append(entry)
        }
    }
    
    private func goToLast(_ entry: PresentationEntry) {
        Logging.log(.stack, "<PresentationRouter> {GO_TO_LAST}", "\tentry: \(entry)")
        if let index = path.lastIndex(type: entry.type) {
            path = PresentationPath(path.entries[0..<index] + [entry])
        } else {
            path.append(entry)
        }
    }
}
