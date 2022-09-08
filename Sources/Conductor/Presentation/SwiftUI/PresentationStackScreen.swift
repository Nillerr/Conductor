import SwiftUI

public struct PresentationStackScreen<Content: View>: View {
    @Environment(\.presentationEntry) public var entry: PresentationEntry
    
    public let type: TypeId
    public let content: (Any, ((Any) -> Void)?) -> Content
    
    public init<Value>(
        _ type: Value.Type,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.type = toTypeIdentifier(type)
        self.content = { (value, callback) in content(value as! Value) }
    }
    
    public init<Value, Output>(
        _ type: Value.Type,
        @ViewBuilder content: @escaping (Value, @escaping (Output) -> Void) -> Content
    ) {
        self.type = toTypeIdentifier(type)
        self.content = { (value, callback) in content(value as! Value, { output in callback?(output) }) }
    }
    
    public var body: some View {
        if entry.type == type {
            content(entry.value, entry.callback)
        } else {
            EmptyView()
        }
    }
}
