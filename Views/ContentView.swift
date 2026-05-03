import SwiftUI

struct ContentView: View {
    @StateObject var vm = SpendlyViewModel()

    var body: some View {
        DashboardView(vm: vm)
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
