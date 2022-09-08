import Foundation

public struct WorkHandle {
    public let work: DispatchWorkItem
    public let immediate: Bool
    
    public init(immediate: Bool = false, block: @escaping () -> Void) {
        self.work = DispatchWorkItem(block: block)
        self.immediate = immediate
    }
}
