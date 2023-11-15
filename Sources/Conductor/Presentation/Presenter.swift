import SwiftUI
import Combine

public struct Presenter {
    private weak var presenter: ObservablePresenter?
    
    public init(presenter: ObservablePresenter? = nil) {
        self.presenter = presenter
    }
    
    public func present(_ value: Any) {
        presenter?.present(value)
    }
    
    public func dismiss() {
        presenter?.dismiss()
    }
}

struct WorkItem {
    let action: () async -> Void
}

extension Task where Success == Never, Failure == Never {
    static func sleep(microseconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(microseconds * 1000))
    }
    
    static func sleep(milliseconds: Double) async throws {
        try await Task.sleep(microseconds: milliseconds * 1000)
    }
    
    static func sleep(seconds: Double) async throws {
        try await Task.sleep(milliseconds: seconds * 1000)
    }
}

public class ObservablePresenter: ObservableObject {
    @Published public var isPresented: Bool = false
    @Published public var presented: Any? = nil
    
    private var queue: [WorkItem] = []
    private var isSettled: Bool = true
    
    public init() {
        // Nothing
    }
    
    public func present(_ value: Any, continuation: (@Sendable () async -> Void)? = nil) {
        Task { @MainActor [weak self] in
            self?._present(value, continuation: continuation)
        }
    }
    
    private func _present(_ value: Any, continuation: (@Sendable () async -> Void)?) {
        let work = WorkItem { @MainActor [weak self] in
            await self?._presentWork(value, continuation: continuation)
        }
        
        queue.append(work)
        scheduleWorkIfSettled()
    }
    
    @MainActor
    private func _presentWork(_ value: Any, continuation: (@Sendable () async -> Void)?) async {
        if isPresented {
            isPresented = false
            
            do {
                try await Task.sleep(milliseconds: 600)
            } catch {
                // Nothing
            }
        }
        
        presented = value
        isPresented = true
        
        await continuation?()
    }
    
    public func dismiss(continuation: (@Sendable () async -> Void)? = nil) {
        Task { @MainActor [weak self] in
            self?._dismiss(continuation: continuation)
        }
    }
    
    private func _dismiss(continuation: (@Sendable () async -> Void)? = nil) {
        let work = WorkItem { @MainActor [weak self] in
            await self?._dismissWork(continuation: continuation)
        }
        
        queue.append(work)
        scheduleWorkIfSettled()
    }
    
    @MainActor
    private func _dismissWork(continuation: (@Sendable () async -> Void)? = nil) async {
        isPresented = false
        
        do {
            try await Task.sleep(milliseconds: 600)
            presented = nil
            await continuation?()
        } catch {
            // Nothing
        }
    }
    
    private func scheduleWorkIfSettled() {
        if isSettled {
            scheduleWork()
        }
    }
    
    private func scheduleWork() {
        guard let work = queue.first else {
            isSettled = false
            return
        }
        
        Task { @MainActor [weak self] in
            await work.action()
            
            self?.queue.removeFirst()
            self?.scheduleWork()
        }
    }
}

struct PresentedKey: EnvironmentKey {
    static var defaultValue: Any? = nil
}

extension EnvironmentValues {
    var presentedView: Any? {
        get { self[PresentedKey.self] }
        set { self[PresentedKey.self] = newValue }
    }
}

extension View {
    func presentedView(_ value: Any) -> some View {
        environment(\.presentedView, value)
    }
}

struct PresentedView<Value, Content: View>: View {
    @Environment(\.presentedView) private var presentedView: Any?
    
    @ViewBuilder let content: (Value) -> Content
    
    var body: some View {
        if let presentedView, let value = presentedView as? Value {
            content(value)
        } else {
            Text("PresentedView: Missing Value")
        }
    }
}

struct PresentedWrapper<Content: View>: View {
    @ObservedObject var presenter: ObservablePresenter
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .environment(\.presentedView, presenter.presented)
    }
}

public struct PresenterView<Root: View, Content: View>: View {
    @ObservedObject var presenter: ObservablePresenter
    
    private let root: Root
    private let content: () -> Content
    
    public init(
        presenter: ObservablePresenter,
        @ViewBuilder root: () -> Root,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.presenter = presenter
        self.root = root()
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            root
        }
        .fullScreenCover(isPresented: $presenter.isPresented) {
            PresentedWrapper(presenter: presenter) {
                content()
            }
        }
    }
}
