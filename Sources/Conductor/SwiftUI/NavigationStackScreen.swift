import SwiftUI

public struct NavigationStackScreen<Content: View>: View {
    @Environment(\.navigationEntry) public var entry: NavigationEntry
    
    public let id: String
    public let content: (AnyHashable) -> Content
    
    public init<Value>(_ type: Value.Type, @ViewBuilder content: @escaping (Value) -> Content) {
        self.id = String(describing: type)
        self.content = { value in content(value as! Value) }
    }
    
    public var body: some View {
        if entry.type == id {
            content(entry.value)
        } else {
            EmptyView()
        }
    }
}
