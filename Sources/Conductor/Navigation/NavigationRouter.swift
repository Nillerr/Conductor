import Combine
import Foundation

public typealias NavigationPath = EntryPath<NavigationEntry>

public class NavigationRouter: ObservableObject {
    public struct Configuration {
        public var operationDelay: DispatchTimeInterval = .milliseconds(650)
        
        public init() {
        }
    }
    
    private let idGenerator: IdGenerator
    private let configuration: Configuration
    
    @Published public internal(set) var path = NavigationPath()
    
    private var workQueue: [WorkHandle] = []
    
    public init(
        idGenerator: IdGenerator = IncrementingIdGenerator(),
        configuration: Configuration = Configuration()
    ) {
        self.idGenerator = idGenerator
        self.configuration = configuration
    }
    
    public func navigate(_ builder: @escaping (inout NavigationBuilder) -> Void) {
        let work = WorkHandle(immediate: true) { [weak self] in self?.performNavigate(builder) }
        enqueueWork([work])
    }
    
    private func performNavigate(_ builder: @escaping (inout NavigationBuilder) -> Void) {
        var navBuilder = NavigationBuilder(idGenerator: idGenerator)
        builder(&navBuilder)
        
        let work = navBuilder.steps.map(createWork(for:))
        enqueueWork(work)
    }
    
    private func enqueueWork(_ work: [WorkHandle]) {
        let currentWork = workQueue
        workQueue.append(contentsOf: work)
        
        if currentWork.isEmpty {
            performNextWork()
        } else {
            // The work will be picked up at the end of the pending work
        }
    }
    
    private func performNextWork() {
        guard let workHandle = workQueue.first else { return }
        workHandle.work()
        
        let delay = workHandle.immediate ? .milliseconds(0) : configuration.operationDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.workQueue.removeFirst()
            self?.performNextWork()
        }
    }
    
    private func createWork(for step: NavigationStep) -> WorkHandle {
        switch step {
        case .popToRoot:
            return WorkHandle { [weak self] in self?.popToRoot() }
        case .pop(let count):
            return WorkHandle { [weak self] in self?.pop(count) }
        case .popToFirst(let type):
            return WorkHandle { [weak self] in self?.popToFirst(type) }
        case .popToLast(let type):
            return WorkHandle { [weak self] in self?.popToLast(type) }
        case .push(let entry):
            return WorkHandle { [weak self] in self?.push(entry) }
        case .goToFirst(let entry):
            return WorkHandle { [weak self] in self?.goToFirst(entry) }
        case .goToLast(let entry):
            return WorkHandle { [weak self] in self?.goToLast(entry) }
        case .invoke(let immediate, let block):
            return WorkHandle(immediate: immediate, work: block)
        }
    }
    
    private func popToRoot() {
        Logging.log(.stack, "<StackRouter> {POP_TO_ROOT}")
        path.clear()
    }
    
    private func pop(_ count: Int) {
        Logging.log(.stack, "<StackRouter> {POP}", "\tcount: \(count)")
        path.removeLast(count)
    }
    
    private func popToFirst(_ type: String) {
        Logging.log(.stack, "<StackRouter> {POP_TO_FIRST}", "\ttype: \(type)")
        if let index = path.firstIndex(type: type) {
            path = NavigationPath(path.entries[0...index])
        }
    }
    
    private func popToLast(_ type: String) {
        Logging.log(.stack, "<StackRouter> {POP_TO_LAST}", "\ttype: \(type)")
        if let index = path.lastIndex(type: type) {
            path = NavigationPath(path.entries[0...index])
        }
    }
    
    private func push(_ entry: NavigationEntry) {
        Logging.log(.stack, "<StackRouter> {PUSH}", "\tentry: \(entry)")
        path.append(entry)
    }
    
    private func goToFirst(_ entry: NavigationEntry) {
        Logging.log(.stack, "<StackRouter> {GO_TO_FIRST}", "\tentry: \(entry)")
        if let index = path.firstIndex(type: entry.type) {
            path = NavigationPath(path.entries[0..<index] + [entry])
        } else {
            path.append(entry)
        }
    }
    
    private func goToLast(_ entry: NavigationEntry) {
        Logging.log(.stack, "<StackRouter> {GO_TO_LAST}", "\tentry: \(entry)")
        if let index = path.lastIndex(type: entry.type) {
            path = NavigationPath(path.entries[0..<index] + [entry])
        } else {
            path.append(entry)
        }
    }
}
