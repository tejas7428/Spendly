import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var vm: SpendlyViewModel
    @State private var showAdd = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "#F5F0FF").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HeroHeaderView(vm: vm)

                    SummaryRowView(vm: vm)
                        .padding(.top, -20)
                        .padding(.horizontal)

                    if !vm.groupedData().isEmpty {
                        ChartCardView(vm: vm)
                            .padding(.top, 24)
                            .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Recent Transactions")
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#1A0A2E"))

                            Spacer()

                            Text("\(vm.expenses.count) items")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)

                        if vm.expenses.isEmpty {
                            EmptyStateView()
                                .padding(.top, 20)
                        } else {
                            ForEach(vm.expenses) { expense in
                                ExpenseRowCard(expense: expense)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 100)
                }
            }

            Button {
                showAdd = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(hex: "#7C3AED"), Color(hex: "#4F46E5")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 62, height: 62)
                        .shadow(color: Color(hex: "#7C3AED").opacity(0.5), radius: 14, y: 6)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 36)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAdd) {
            AddExpenseView(vm: vm)
        }
    }
}

// MARK: - Hero Header
struct HeroHeaderView: View {
    @ObservedObject var vm: SpendlyViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "#7C3AED"), Color(hex: "#312E81")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 220)
                .offset(x: 120, y: -30)

            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 160)
                .offset(x: -100, y: 10)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hey there 👋")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))

                        Text("Spendly")
                            .font(.custom("Georgia", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 46, height: 46)

                        Image(systemName: "chart.pie.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 24)

                HStack(spacing: 8) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))

                    Text(formatCurrency(vm.monthlyTotal))
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .padding(.top, 8)
            }
        }
        .frame(height: 220)
    }
}

// MARK: - Summary Row
struct SummaryRowView: View {
    @ObservedObject var vm: SpendlyViewModel

    var body: some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: "Total",
                value: formatCurrency(vm.totalAmount),
                icon: "indianrupeesign.circle.fill",
                color: Color(hex: "#7C3AED")
            )
            SummaryCard(
                title: "Entries",
                value: "\(vm.expenses.count)",
                icon: "list.bullet.rectangle.fill",
                color: Color(hex: "#059669")
            )
            SummaryCard(
                title: "Top",
                value: vm.topCategory(),
                icon: "star.fill",
                color: Color(hex: "#F59E0B")
            )
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1A0A2E"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.07), radius: 10, y: 4)
    }
}

// MARK: - Chart Card
struct ChartCardView: View {
    @ObservedObject var vm: SpendlyViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.custom("Georgia", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#1A0A2E"))

            Chart(vm.groupedData(), id: \.key) { item in
                BarMark(
                    x: .value("Category", item.key),
                    y: .value("Amount", item.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#7C3AED"), Color(hex: "#A78BFA")],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(8)
                .annotation(position: .top) {
                    Text(formatCurrency(item.value))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#7C3AED"))
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .frame(height: 180)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(vm.groupedData(), id: \.key) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "#7C3AED").opacity(0.7))
                            .frame(width: 8, height: 8)
                        Text(item.key)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(vm.percentage(for: item.key)))%")
                            .font(.caption2.bold())
                            .foregroundColor(Color(hex: "#7C3AED"))
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.07), radius: 12, y: 4)
    }
}

// MARK: - Expense Row Card
struct ExpenseRowCard: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#EDE9FE"))
                    .frame(width: 50, height: 50)

                Text(expense.categoryEmoji)
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title.isEmpty ? expense.category : expense.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A0A2E"))

                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(formatCurrency(expense.amount))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#7C3AED"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 3)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 14) {
            Text("💸")
                .font(.system(size: 54))

            Text("No expenses yet")
                .font(.custom("Georgia", size: 18))
                .foregroundColor(Color(hex: "#1A0A2E"))

            Text("Tap + to log your first expense")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

#Preview {
    NavigationStack {
        DashboardView(vm: SpendlyViewModel())
    }
}
