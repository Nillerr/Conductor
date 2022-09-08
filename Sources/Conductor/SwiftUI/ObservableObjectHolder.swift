import Combine

internal class ObservableObjectHolder<Object : ObservableObject>: ObservableObject {
    private var subscription: AnyCancellable?
    
    var object: Object? {
        didSet {
            subscription = object?.objectWillChange
                .sink(receiveValue: { [weak self] _ in self?.objectWillChange.send() })
        }
    }
    
    init() {
        self.object = nil
    }
    
    init(object: Object) {
        self.object = object
    }
}
