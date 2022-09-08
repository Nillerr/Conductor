import SwiftUI

@available(iOS 14, *)
public struct PresentationStack<Root: View, Routes: View>: View {
    @StateObject private var defaultRouter = PresentationRouter()
    
    @ObservedObject private var routerHolder: ObservableObjectHolder<PresentationRouter>
    
    public var router: PresentationRouter {
        routerHolder.object ?? defaultRouter
    }
    
    public let root: Root
    public let routes: Routes
    
    public var activeLinkPresentationStyle: Binding<PresentationStyle?> {
        Binding {
            router.path.entries.first?.style
        } set: { newValue in
            let routerPath = router.path
            if let child = router.path.entries.last, newValue == nil {
                if let popped = router.path.popLast(id: child.id) {
                    Logging.log(.modal, "<Content> {POP}", "\trouter: \(routerPath)", "\tpopped: \(popped)")
                }
            }
        }
    }
    
    public init(
        router: PresentationRouter,
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
    
    internal init(router: PresentationRouter, root: Root, routes: Routes) {
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
                .environment(\.presentationRouter, router)
            
            Link(router: router, activePresentationStyle: activeLinkPresentationStyle, routes: routes, path: router.path)
        }
    }
    
    public struct Link: View {
        @ObservedObject public private(set) var router: PresentationRouter
        
        @Binding public private(set) var activePresentationStyle: PresentationStyle?
        
        public let routes: Routes
        
        public let path: PresentationPath
        
        public var body: some View {
            PresentationLink(presentationStyle: $activePresentationStyle) {
                var descendants = path
                if let entry = descendants.popFirst() {
                    Entry(router: router, routes: routes, entry: entry, path: descendants)
                } else {
                    Text("Unexpected state: No descendants of navigation")
                }
            }
        }
    }
    
    public struct PresentationLink<Content: View>: View {
        @Binding public private(set) var presentationStyle: PresentationStyle?
        
        private var isFullScreenCoverActive: Binding<Bool> {
            Binding {
                presentationStyle == .fullScreenCover
            } set: { newValue in
                if !newValue && presentationStyle == .fullScreenCover {
                    presentationStyle = nil
                }
            }
        }
        
        private var isSheetActive: Binding<Bool> {
            Binding {
                presentationStyle == .fullScreenCover
            } set: { newValue in
                if !newValue && presentationStyle == .fullScreenCover {
                    presentationStyle = nil
                }
            }
        }
        
        public let content: () -> Content
        
        public init(
            presentationStyle: Binding<PresentationStyle?>,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self._presentationStyle = presentationStyle
            self.content = content
        }
        
        public var body: some View {
            VStack {}
                .fullScreenCover(isPresented: isFullScreenCoverActive, onDismiss: nil) {
                    content()
                }
            
            VStack {}
                .sheet(isPresented: isSheetActive, onDismiss: nil) {
                    content()
                }
        }
    }
    
    public struct Entry: View {
        @ObservedObject public private(set) var router: PresentationRouter
        
        public let routes: Routes
        
        public let entry: PresentationEntry
        
        public let path: PresentationPath
        
        public var activeLinkPresentationStyle: Binding<PresentationStyle?> {
            Binding {
                path.entries.first?.style
            } set: { newValue in
                let routerPath = router.path
                if let child = path.entries.first, newValue == nil {
                    if let popped = router.path.popLast(id: child.id) {
                        Logging.log(.modal, "<Entry> {POP}", "\tentry: \(entry)", "\trouter: \(routerPath)", "\tpath: \(path)", "\tpopped: \(popped)")
                    }
                }
            }
        }
        
        public var body: some View {
            routes
                .environment(\.presentationEntry, entry)
                .environment(\.presentationRouter, router)
            
            Link(router: router, activePresentationStyle: activeLinkPresentationStyle, routes: routes, path: path)
        }
    }
}
