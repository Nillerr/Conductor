import SwiftUI

struct NavigationEntryEnvironmentKey: EnvironmentKey {
    static var defaultValue = NavigationEntry(
        id: "?",
        type: "DefaultValue",
        value: "default"
    )
}

struct NavigationRouterEnvironmentKey: EnvironmentKey {
    static var defaultValue = NavigationRouter(
        idGenerator: IncrementingIdGenerator(),
        configuration: .init()
    )
}

struct PresentationEntryEnvironmentKey: EnvironmentKey {
    static var defaultValue = PresentationEntry(
        id: "?",
        type: "DefaultValue",
        value: "default",
        style: .fullScreenCover
    )
}

struct PresentationRouterEnvironmentKey: EnvironmentKey {
    static var defaultValue = PresentationRouter(
        idGenerator: IncrementingIdGenerator(),
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
    
    public var presentationEntry: PresentationEntry {
        get { self[PresentationEntryEnvironmentKey.self] }
        set { self[PresentationEntryEnvironmentKey.self] = newValue }
    }
    
    public var presentationRouter: PresentationRouter {
        get { self[PresentationRouterEnvironmentKey.self] }
        set { self[PresentationRouterEnvironmentKey.self] = newValue }
    }
}
