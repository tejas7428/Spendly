import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var vm: SpendlyViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = "Food"
    @State private var date = Date()
    @State private var showError = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color(hex: "#F5F0FF").ignoresSafeArea()

            VStack(spacing: 0) {
                // Sheet Handle + Title
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)

                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 26))
                        }

                        Spacer()

                        Text("New Expense")
                            .font(.custom("Georgia", size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#1A0A2E"))

                        Spacer()

                        Circle()
                            .fill(Color.clear)
                            .frame(width: 26)
                    }
                    .padding(.horizontal, 24)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Amount Input
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Amount", systemImage: "indianrupeesign.circle")
                                .font(.caption.bold())
                                .foregroundColor(.gray)

                            HStack {
                                Text("₹")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color(hex: "#7C3AED"))

                                TextField("0.00", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(hex: "#1A0A2E"))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(showError && amount.isEmpty ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
                        }

                        // Title Input
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Title (optional)", systemImage: "pencil")
                                .font(.caption.bold())
                                .foregroundColor(.gray)

                            TextField("e.g. Lunch at Cafe, Flight ticket...", text: $title)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
                                .foregroundColor(Color(hex: "#1A0A2E"))
                        }

                        // Category Grid
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Category", systemImage: "tag")
                                .font(.caption.bold())
                                .foregroundColor(.gray)

                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(vm.categories, id: \.self) { cat in
                                    let isSelected = selectedCategory == cat
                                    let dummyExpense = Expense(title: "", amount: 0, category: cat, date: Date())

                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedCategory = cat
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            Text(dummyExpense.categoryEmoji)
                                                .font(.system(size: 24))

                                            Text(cat)
                                                .font(.caption.bold())
                                                .foregroundColor(isSelected ? .white : Color(hex: "#1A0A2E"))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            isSelected
                                                ? AnyView(LinearGradient(
                                                    colors: [Color(hex: "#7C3AED"), Color(hex: "#4F46E5")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing))
                                                : AnyView(Color.white)
                                        )
                                        .cornerRadius(16)
                                        .shadow(
                                            color: isSelected ? Color(hex: "#7C3AED").opacity(0.4) : Color.black.opacity(0.05),
                                            radius: isSelected ? 10 : 6,
                                            y: 3
                                        )
                                        .scaleEffect(isSelected ? 1.04 : 1.0)
                                    }
                                }
                            }
                        }

                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Date", systemImage: "calendar")
                                .font(.caption.bold())
                                .foregroundColor(.gray)

                            DatePicker("", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
                        }

                        if showError {
                            Text("⚠️ Please enter a valid amount")
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Save Button
                        Button {
                            guard let amt = Double(amount), amt > 0 else {
                                withAnimation { showError = true }
                                return
                            }
                            vm.addExpense(
                                title: title,
                                amount: amt,
                                category: selectedCategory,
                                date: date
                            )
                            dismiss()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("Save Expense")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#7C3AED"), Color(hex: "#4F46E5")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(18)
                            .shadow(color: Color(hex: "#7C3AED").opacity(0.45), radius: 14, y: 6)
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
        }
        .onChange(of: amount) { _ in
            if showError { showError = false }
        }
    }
}

#Preview {
    AddExpenseView(vm: SpendlyViewModel())
}
