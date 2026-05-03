import Foundation
import SwiftUI

class SpendlyViewModel: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet { saveData() }
    }

    let categories = ["Food", "Travel", "Shopping", "Bills", "Health", "Fun"]

    var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var monthlyExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
    }

    var monthlyTotal: Double {
        monthlyExpenses.reduce(0) { $0 + $1.amount }
    }

    init() { loadData() }

    func addExpense(title: String, amount: Double, category: String, date: Date) {
        let newExpense = Expense(title: title, amount: amount, category: category, date: date)
        expenses.insert(newExpense, at: 0)
    }

    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
    }

    func groupedData() -> [(key: String, value: Double)] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        let mapped = grouped.mapValues { $0.reduce(0) { $0 + $1.amount } }
        return mapped.sorted { $0.value > $1.value }
    }

    func percentage(for category: String) -> Double {
        guard totalAmount > 0 else { return 0 }
        let catTotal = expenses.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
        return (catTotal / totalAmount) * 100
    }

    func topCategory() -> String {
        groupedData().first?.key ?? "—"
    }

    // MARK: - Persistence
    func saveData() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "spendly_expenses")
        }
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "spendly_expenses"),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
    }
}
