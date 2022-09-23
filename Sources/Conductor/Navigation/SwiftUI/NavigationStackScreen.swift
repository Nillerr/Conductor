import SwiftUI

public struct NavigationStackScreen<Content: View>: View {
    @Environment(\.navigationEntry) public var entry: NavigationEntry
    @Environment(\.navigationRouter) public var navigation: NavigationRouter
    
    public let type: TypeId
    public let onDismiss: (Any) -> Void
    public let content: (Any) -> Content
    
    public init<Value>(_ type: Value.Type, onDismiss: @escaping (Value) -> Void = { _ in }, @ViewBuilder content: @escaping (Value) -> Content) {
        self.type = toTypeIdentifier(type)
        self.onDismiss = { value in onDismiss(value as! Value) }
        self.content = { value in content(value as! Value) }
    }
    
    public var body: some View {
        if entry.type == type {
            content(entry.value)
                .onDisappear {
                    if !navigation.path.contains(where: { e in e.id == entry.id && e.type == entry.type }) {
                        onDismiss(entry.value)
                    }
                }
        } else {
            EmptyView()
        }
    }
}
