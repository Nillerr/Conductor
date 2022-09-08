public enum Logging {
    public enum Category: CustomStringConvertible {
        case stack
        case modal
        
        public var description: String {
            switch self {
            case .stack:
                return "Stack"
            case .modal:
                return "Modal"
            }
        }
    }
    
    public static var categories: Set<Category> = []
    
    private static func isEnabled(_ category: Category) -> Bool {
        categories.contains(category)
    }
    
    public static func log(_ category: Category, _ messages: String...) {
        if isEnabled(category) {
            for message in messages {
                print("[Conductor] \(category): \(message)")
            }
        }
    }
}
