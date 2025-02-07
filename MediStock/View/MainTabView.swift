import SwiftUI



struct MainTabView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var medicineStore: MedicineStockViewModel
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack() {
            TabView {
                AisleListView()
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Aisles")
                            .accessibilityIdentifier(AccessID.tabAisles)
                    }
                    

                AllMedicinesView()
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("All Medicines")
                            .accessibilityIdentifier(AccessID.tabAllMedicines)
                    }
            }
            .toolbar {
                MedicActionsToolbar(showingAddSheet: $showingAddSheet)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddMedicineSheet()
        }
    }
}



struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(SessionStore())
            .environmentObject(MedicineStockViewModel())
    }
}
