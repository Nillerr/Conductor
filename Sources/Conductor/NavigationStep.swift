enum NavigationStep {
    case popToRoot
    case pop(Int)
    case popToFirst(String)
    case popToLast(String)
    case push(NavigationEntry)
    case goToFirst(NavigationEntry)
    case goToLast(NavigationEntry)
    case invoke(() -> Void)
}
