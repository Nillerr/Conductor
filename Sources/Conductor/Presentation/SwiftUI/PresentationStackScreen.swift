import SwiftUI

public struct PresentationStackScreen<Content: View>: View {
    @Environment(\.presentationEntry) public var entry: PresentationEntry
    
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
