import Combine
import Foundation

public typealias PresentationPath = EntryPath<PresentationEntry>

extension Collection {
    internal func forEach(delay: DispatchTimeInterval, block: @escaping (Element) -> Void) {
        enumerated().forEach { offset, element in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * offset) {
                block(element)
            }
        }
    }
}

internal func *(lhs: DispatchTimeInterval, rhs: Int) -> DispatchTimeInterval {
    switch lhs {
    case .never:
        return .never
    case .seconds(let seconds):
        return .seconds(seconds * rhs)
    case .microseconds(let microseconds):
        return .microseconds(microseconds * rhs)
    case .milliseconds(let milliseconds):
        return .milliseconds(milliseconds * rhs)
    case .nanoseconds(let nanoseconds):
        return .nanoseconds(nanoseconds * rhs)
    @unknown default:
        return .never
    }
}

extension DispatchTimeInterval {
    var totalNanoSeconds: Int? {
        switch self {
        case .never:
            return nil
        case .seconds(let seconds):
            return seconds * 1_000_000_000
        case .milliseconds(let milliseconds):
            return milliseconds * 1_000_000
        case .microseconds(let microseconds):
            return microseconds * 1_000
        case .nanoseconds(let nanoseconds):
            return nanoseconds
        @unknown default:
            return nil
        }
    }
}

internal func +(lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> DispatchTimeInterval {
    if let lhs = lhs.totalNanoSeconds, let rhs = rhs.totalNanoSeconds {
        return .nanoseconds(lhs + rhs)
    } else {
        return .never
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
    
    private var workQueue: [TimedWorkFactory] = []
    
    public init(
        idGenerator: IdGenerator = IncrementingIdGenerator(),
        configuration: Configuration = Configuration()
    ) {
        self.idGenerator = idGenerator
        self.configuration = configuration
    }
    
    public func navigate(_ builder: @escaping (inout PresentationBuilder) -> Void) {
        let workFactory = TimedWorkFactory { [weak self] in
            TimedWork(duration: .seconds(0)) {
                self?.performNavigate(builder)
            }
        }
        
        enqueueWork([workFactory])
    }
    
    private func performNavigate(_ builder: @escaping (inout PresentationBuilder) -> Void) {
        var navBuilder = PresentationBuilder(idGenerator: idGenerator)
        builder(&navBuilder)
        
        let work = navBuilder.steps.map(createWork(for:))
        enqueueWork(work)
    }
    
    private func enqueueWork(_ work: [TimedWorkFactory]) {
        let currentWork = workQueue
        workQueue.append(contentsOf: work)
        
        if currentWork.isEmpty {
            performNextWork()
        } else {
            // The work will be picked up at the end of the pending work
        }
    }
    
    private func performNextWork() {
        guard let workFactory = workQueue.first else { return }
        
        let work = workFactory.work()
        work.perform()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + work.duration) { [weak self] in
            self?.workQueue.removeFirst()
            self?.performNextWork()
        }
    }
    
    private func createWork(for step: PresentationStep) -> TimedWorkFactory {
        switch step {
        case .dismiss:
            return createStandardWork { [weak self] in self?.dismiss() }
        case .present(let entry):
            return createStandardWork { [weak self] in self?.present(entry) }
        case .go(let entry):
            return createGoWork(for: entry)
        case .replace(let entry):
            return createStandardWork { [weak self] in self?.replace(entry) }
        case .invoke(let immediate, let block):
            let duration = immediate ? .seconds(0) : configuration.operationDelay
            return TimedWorkFactory {
                TimedWork(duration: duration, perform: block)
            }
        }
    }
    
    private func createStandardWork(perform: @escaping () -> Void) -> TimedWorkFactory {
        let duration = configuration.operationDelay
        
        let workFactory = TimedWorkFactory {
            TimedWork(duration: duration, perform: perform)
        }
        
        return workFactory
    }
    
    private func createGoWork(for entry: PresentationEntry) -> TimedWorkFactory {
        return TimedWorkFactory { [weak self] in
            guard let `self` = self else { return .none }
            
            let operationDelay = self.configuration.operationDelay
            
            var operations: [TimedWork] = []
            
            if let _ = self.path.lastIndex(type: entry.type) {
                self.path.reversed().enumerated().forEach { offset, pathEntry in
                    if pathEntry.type == entry.type {
                        let work = TimedWork(duration: .milliseconds(0), perform: { [weak self] in
                            self?.replace(entry)
                        })
                        
                        return operations.append(work)
                    } else {
                        let work = TimedWork(duration: operationDelay * offset) { [weak self] in
                            self?.dismiss()
                        }
                        
                        operations.append(work)
                    }
                }
            } else {
                let work = TimedWork(duration: operationDelay) { [weak self] in
                    self?.present(entry)
                }
                
                operations.append(work)
            }
            
            let totalDuration = operations.reduce(.seconds(0)) { delay, work in
                delay + work.duration
            }
            
            return TimedWork(duration: totalDuration) {
                operations.enumerated().forEach { offset, work in
                    let delay = operations.prefix(upTo: offset)
                        .reduce(.seconds(0)) { delay, work in delay + work.duration }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        work.perform()
                    }
                }
            }
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
    
    private func replace(_ entry: PresentationEntry) {
        Logging.log(.stack, "<PresentationRouter> {REPLACE}", "\tentry: \(entry)")
        
        var copy = path
        if let last = copy.popLast() {
            let clone = PresentationEntry(id: last.id, type: entry.type, value: entry.value, style: last.style)
            copy.append(clone)

            path = copy
        }
    }
}
