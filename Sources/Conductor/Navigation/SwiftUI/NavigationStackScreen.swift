import SwiftUI

public struct NavigationStackScreen<Content: View>: View {
    @Environment(\.navigationEntry) public var entry: NavigationEntry
    
    public let type: String
    public let content: (AnyHashable) -> Content
    
    public init<Value>(_ type: Value.Type, @ViewBuilder content: @escaping (Value) -> Content) {
        self.type = toTypeIdentifier(type)
        self.content = { value in content(value as! Value) }
    }
    
    public var body: some View {
        if entry.type == type {
            content(entry.value)
        } else {
            EmptyView()
        }
    }
}
