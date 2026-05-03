import Foundation

struct Expense: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: String
    var date: Date

    var categoryEmoji: String {
        switch category {
        case "Food":      return "🍔"
        case "Travel":    return "✈️"
        case "Shopping":  return "🛍️"
        case "Bills":     return "📄"
        case "Health":    return "💊"
        case "Fun":       return "🎮"
        default:          return "💸"
        }
    }
}
