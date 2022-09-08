public enum PresentationStep {
    case dismiss
    case present(PresentationEntry)
    case goToFirst(PresentationEntry)
    case goToLast(PresentationEntry)
    case invoke(() -> Void)
}
