import SwiftUI

internal func readOnlyBinding<Value>(_ get: @escaping () -> Value) -> Binding<Value> {
    return Binding(get: get, set: { _ in })
}
