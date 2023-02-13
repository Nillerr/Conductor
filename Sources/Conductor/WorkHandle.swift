import Foundation

public struct TimedWork {
    public let duration: DispatchTimeInterval
    public let perform: () -> Void
    
    public init(duration: DispatchTimeInterval, perform: @escaping () -> Void) {
        self.duration = duration
        self.perform = perform
    }
    
    static let none = TimedWork(duration: .seconds(0), perform: {})
}

public struct TimedWorkFactory {
    public let work: () -> TimedWork
    
    public init(work: @escaping () -> TimedWork) {
        self.work = work
    }
}
