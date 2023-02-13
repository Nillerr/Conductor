public enum PresentationStep {
    case dismiss
    case present(PresentationEntry)
    case go(PresentationEntry)
    case replace(PresentationEntry)
    case invoke(Bool, () -> Void)
}
