import SwiftUI

struct NavigationEntryEnvironmentKey: EnvironmentKey {
    static var defaultValue = NavigationEntry(
        id: "?",
        type: "DefaultValue",
        value: AnyHashable("default")
    )
}

struct NavigationRouterEnvironmentKey: EnvironmentKey {
    static var defaultValue = NavigationRouter(
        idGenerator: IncrementingNavigationIdGenerator(),
        configuration: .init()
    )
}

extension EnvironmentValues {
    public var navigationEntry: NavigationEntry {
        get { self[NavigationEntryEnvironmentKey.self] }
        set { self[NavigationEntryEnvironmentKey.self] = newValue }
    }
    
    public var navigationRouter: NavigationRouter {
        get { self[NavigationRouterEnvironmentKey.self] }
        set { self[NavigationRouterEnvironmentKey.self] = newValue }
    }
}
