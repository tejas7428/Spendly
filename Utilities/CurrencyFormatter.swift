import Foundation

func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_IN")
    return formatter.string(from: NSNumber(value: amount)) ?? "₹0"
}
