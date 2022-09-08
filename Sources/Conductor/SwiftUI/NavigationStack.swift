import SwiftUI

public struct NavigationStack<Root: View, Routes: View>: View {
    public let router: NavigationRouter
    
    public let root: Root
    public let routes: Routes
    
    public init(router: NavigationRouter, @ViewBuilder root: () -> Root, @ViewBuilder routes: () -> Routes) {
        self.router = router
        self.root = root()
        self.routes = routes()
    }
    
    public var body: some View {
        NavigationView {
            NavigationStackContent(router: router, root: root, routes: routes)
        }
        .navigationViewStyle(.stack)
    }
}
