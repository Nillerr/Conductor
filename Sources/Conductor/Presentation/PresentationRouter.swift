import Combine
import Foundation

public typealias PresentationPath = EntryPath<PresentationEntry>

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
        idGenerator: IdGenerator = IncrementingIdGenerator(),
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
