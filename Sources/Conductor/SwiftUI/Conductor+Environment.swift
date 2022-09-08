import SwiftUI

struct NavigationEntryEnvironmentKey: EnvironmentKey {
    static var defaultValue = NavigationEntry(id: "", type: "", value: AnyHashable(""))
}

struct NavigationRouterEnvironmentKey: EnvironmentKey {
    static var defaultValue = NavigationRouter(idGenerator: .init(), configuration: .init())
}
