import SwiftUI

public struct NavigationStackContent<Root: View, Routes: View>: View {
    @StateObject private var defaultRouter = NavigationRouter()
    
    @ObservedObject private var routerHolder: ObservableObjectHolder<NavigationRouter>
    
    public var router: NavigationRouter {
        routerHolder.object ?? defaultRouter
    }
    
    public let root: Root
    public let routes: Routes
    
    public var isLinkActive: Binding<Bool> {
        Binding {
            !router.path.isEmpty
        } set: { newValue in
            let routerPath = router.path
            if let child = router.path.entries.last, !newValue {
                if let popped = router.path.popLast(id: child.id) {
                    Logging.log(.stack, "<Content> {POP}", "\trouter: \(routerPath)", "\tpopped: \(popped)")
                }
            }
        }
    }
    
    public init(
        router: NavigationRouter,
        @ViewBuilder root: () -> Root,
        @ViewBuilder routes: () -> Routes
    ) {
        self.routerHolder = ObservableObjectHolder(object: router)
        self.root = root()
        self.routes = routes()
    }
    
    public init(
        @ViewBuilder root: () -> Root,
        @ViewBuilder routes: () -> Routes
    ) {
        self.routerHolder = ObservableObjectHolder()
        self.root = root()
        self.routes = routes()
    }
    
    internal init(router: NavigationRouter, root: Root, routes: Routes) {
        self.routerHolder = ObservableObjectHolder(object: router)
        self.root = root
        self.routes = routes
    }
    
    internal init(root: Root, routes: Routes) {
        self.routerHolder = ObservableObjectHolder()
        self.root = root
        self.routes = routes
    }
    
    public var body: some View {
        VStack {
            root
                .environment(\.navigationRouter, router)
            
            Link(
                router: router,
                isActive: isLinkActive,
                routes: routes,
                path: readOnlyBinding { router.path }
            )
        }
    }
    
    public struct Link: View {
        @ObservedObject public private(set) var router: NavigationRouter
        
        @Binding public private(set) var isActive: Bool
        
        public let routes: Routes
        
        @Binding public var path: NavigationPath
        
        public var body: some View {
            NavigationLink(isActive: $isActive) {
                if let _ = path.first {
                    let entry = readOnlyBinding { path.first! }
                    let descendants = readOnlyBinding { path.dropFirst() }
                    Entry(router: router, routes: routes, entry: entry, path: descendants)
                } else {
                    Text("Unexpected state: No descendants of navigation")
                }
            } label: { EmptyView() }
                .isDetailLink(false)
        }
    }
    
    public struct Entry: View {
        @ObservedObject public private(set) var router: NavigationRouter
        
        public let routes: Routes
        
        @Binding public var entry: NavigationEntry
        
        @Binding public var path: NavigationPath
        
        public var isLinkActive: Binding<Bool> {
            Binding {
                !path.isEmpty
            } set: { newValue in
                let routerPath = router.path
                if let child = path.entries.first, !newValue {
                    if let popped = router.path.popLast(id: child.id) {
                        Logging.log(.stack, "<Entry> {POP}", "\tentry: \(entry)", "\trouter: \(routerPath)", "\tpath: \(path)", "\tpopped: \(popped)")
                    }
                }
            }
        }
        
        public var body: some View {
            routes
                .environment(\.navigationEntry, entry)
                .environment(\.navigationRouter, router)
            
            Link(router: router, isActive: isLinkActive, routes: routes, path: $path)
        }
    }
}
