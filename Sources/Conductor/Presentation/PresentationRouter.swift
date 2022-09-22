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
    
    private var workQueue: [WorkHandle] = []
    
    public init(
        idGenerator: IdGenerator = IncrementingIdGenerator(),
        configuration: Configuration = Configuration()
    ) {
        self.idGenerator = idGenerator
        self.configuration = configuration
    }
    
    public func navigate(_ builder: @escaping (inout PresentationBuilder) -> Void) {
        let work = WorkHandle(immediate: true) { [weak self] in self?.performNavigate(builder) }
        enqueueWork([work])
    }
    
    private func performNavigate(_ builder: @escaping (inout PresentationBuilder) -> Void) {
        var navBuilder = PresentationBuilder(idGenerator: idGenerator)
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
    
    private func createWork(for step: PresentationStep) -> WorkHandle {
        switch step {
        case .dismiss:
            return WorkHandle { [weak self] in self?.dismiss() }
        case .present(let entry):
            return WorkHandle { [weak self] in self?.present(entry) }
        case .invoke(let immediate, let block):
            return WorkHandle(immediate: immediate, work: block)
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
}
