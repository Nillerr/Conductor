import SwiftUI

public struct Conductor {
    private let _push: (Any, TypeId) -> Void
    private let _pop: () -> Void
    private let _popToRoot: () -> Void
    
    public init(router: PresentationRouter) {
        self._push = { value, type in
            router.navigate { modal in
                modal.present(value, type: type)
            }
        }
        
        self._pop = {
            router.navigate { modal in
                modal.dismiss()
            }
        }
        
        self._popToRoot = {
            router.navigate { modal in
                router.path.forEach { _ in modal.dismiss() }
            }
        }
    }
    
    public init(router: NavigationRouter) {
        self._push = { value, type in
            router.navigate { stack in
                stack.push(value, type: type)
            }
        }
        
        self._pop = {
            router.navigate { stack in
                stack.pop()
            }
        }
        
        self._popToRoot = {
            router.navigate { stack in
                stack.popToRoot()
            }
        }
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
    public static var defaultValue = Conductor(router: PresentationRouter())
}

extension EnvironmentValues {
    public var conductor: Conductor {
        get { self[ConductorEnvironmentKey.self] }
        set { self[ConductorEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func conductor(_ router: PresentationRouter) -> some View {
        environment(\.conductor, Conductor(router: router))
    }
    
    public func conductor(_ router: NavigationRouter) -> some View {
        environment(\.conductor, Conductor(router: router))
    }
}
