import SwiftUI

public struct NavigationStackContent<Root: View, Routes: View>: View {
    @ObservedObject public private(set) var router: NavigationRouter
    
    public let root: Root
    public let routes: Routes
    
    public var isLinkActive: Binding<Bool> {
        Binding {
            !router.path.isEmpty
        } set: { newValue in
            let routerPath = router.path
            if let child = router.path.entries.last, !newValue {
                if let popped = router.path.popLast(id: child.id) {
                    Logging.log(.stack, "<NavigationStack> {POP}", "\trouter: \(routerPath)", "\tpopped: \(popped)")
                }
            }
        }
    }
    
    public init(router: NavigationRouter, @ViewBuilder root: () -> Root, @ViewBuilder routes: () -> Routes) {
        self.router = router
        self.root = root()
        self.routes = routes()
    }
    
    internal init(router: NavigationRouter, root: Root, routes: Routes) {
        self.router = router
        self.root = root
        self.routes = routes
    }
    
    public var body: some View {
        VStack {
            root
            
            Link(router: router, isActive: isLinkActive, routes: routes, path: router.path)
        }
    }
    
    public struct Link: View {
        @ObservedObject public private(set) var router: NavigationRouter
        
        @Binding public private(set) var isActive: Bool
        
        public let routes: Routes
        
        public let path: NavigationPath
        
        public var body: some View {
            NavigationLink(isActive: $isActive) {
                var descendants = path
                if let entry = descendants.popFirst() {
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
        
        public let entry: NavigationEntry
        
        public let path: NavigationPath
        
        public var isLinkActive: Binding<Bool> {
            Binding {
                !path.isEmpty
            } set: { newValue in
                let routerPath = router.path
                if let child = path.entries.first, !newValue, let popped = router.path.popLast(id: child.id) {
                    Logging.log(.stack, "<Entry> {POP}", "\tentry: \(entry)", "\trouter: \(routerPath)", "\tpath: \(path)", "\tpopped: \(popped)")
                }
            }
        }
        
        public var body: some View {
            routes
                .environment(\.navigationEntry, entry)
                .environment(\.navigationRouter, router)
            
            Link(router: router, isActive: isLinkActive, routes: routes, path: path)
        }
    }
}
