public enum PresentationStyle: Equatable {
    case fullScreenCover
    case sheet
}

public struct PresentationEntry: NavigableEntry {
    public let id: String
    public let type: TypeId
    public let value: Any
    public let style: PresentationStyle
    public let callback: ((Any) -> Void)?
}
