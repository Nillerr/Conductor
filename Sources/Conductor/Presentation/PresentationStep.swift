public enum PresentationStep {
    case dismiss
    case present(PresentationEntry)
    case invoke(Bool, () -> Void)
}
