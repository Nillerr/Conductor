import SwiftUI

public struct PresentationStackScreen<Content: View>: View {
    @Environment(\.presentationEntry) public var entry: PresentationEntry
    
    public let type: TypeId
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
