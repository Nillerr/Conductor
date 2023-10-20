import SwiftUI

private func printNotImplemented() {
    print("[Conductor] A router must be injected using `.conductor(router)`, in order to use `@Environment(\\.conductor)`.")
}

private func printRouterReleased() {
    print("[Conductor] The router associated with this Conductor was released. Make sure the router is stored in a `@State` property, `ViewModel` or is otherwise retained elsewhere.")
}

public struct Conductor {
    private let _push: (Any, TypeId) -> Void
    private let _pop: () -> Void
    private let _popToRoot: () -> Void
    
    public var isModal: Bool
    
    public init(router: PresentationRouter) {
        self.isModal = true
        
        self._push = { [weak router] value, type in
            guard let router else { return printRouterReleased() }
            
            router.navigate { modal in
                modal.present(value, type: type)
            }
        }
        
        self._pop = { [weak router] in
            guard let router else { return printRouterReleased() }
            
            router.navigate { modal in
                modal.dismiss()
            }
        }
        
        self._popToRoot = { [weak router] in
            guard let router else { return printRouterReleased() }
            
            router.navigate { [weak router] modal in
                router?.path.forEach { _ in modal.dismiss() }
            }
        }
    }
    
    public init(router: NavigationRouter) {
        self.isModal = false
        
        self._push = { [weak router] value, type in
            router?.navigate { stack in
                stack.push(value, type: type)
            }
        }
        
        self._pop = { [weak router] in
            router?.navigate { stack in
                stack.pop()
            }
        }
        
        self._popToRoot = { [weak router] in
            router?.navigate { stack in
                stack.popToRoot()
            }
        }
    }
    
    internal init() {
        self.isModal = false
        
        self._push = { _, _ in printNotImplemented() }
        self._pop = { printNotImplemented() }
        self._popToRoot = { printNotImplemented() }
    }
    
    public func push<Value>(_ view: Value) {
        let type = toTypeIdentifier(Value.self)
        self._push(view, type)
    }
    
    public func pop() {
        self._pop()
    }
    
    public func popToRoot() {
        self._popToRoot()
    }
}

public struct ConductorEnvironmentKey : EnvironmentKey {
    public static var defaultValue = Conductor()
}

extension EnvironmentValues {
    public var conductor: Conductor {
        get { self[ConductorEnvironmentKey.self] }
        set { self[ConductorEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func conductor(_ conductor: Conductor) -> some View {
        environment(\.conductor, conductor)
    }
    
    public func conductor(_ router: PresentationRouter) -> some View {
        environment(\.conductor, Conductor(router: router))
    }
    
    public func conductor(_ router: NavigationRouter) -> some View {
        environment(\.conductor, Conductor(router: router))
    }
}
