public enum PresentationStyle {
    case fullScreenCover
    case sheet
}

public struct PresentationEntry: NavigableEntry {
    public let id: String
    public let type: String
    public let value: AnyHashable
    public let style: PresentationStyle
}
