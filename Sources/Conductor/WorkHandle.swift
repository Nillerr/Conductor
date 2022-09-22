import Foundation

public struct WorkHandle {
    public let work: () -> Void
    public let immediate: Bool
    
    public init(immediate: Bool = false, work: @escaping () -> Void) {
        self.work = work
        self.immediate = immediate
    }
}
