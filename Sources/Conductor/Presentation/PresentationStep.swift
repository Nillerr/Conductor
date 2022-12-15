public enum PresentationStep {
    case dismiss
    case present(PresentationEntry)
    case replace(PresentationEntry)
    case invoke(Bool, () -> Void)
}
