import SwiftUI



struct MainTabView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var medicineStore: MedicineStockViewModel
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            TabView {
                AisleListView()
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Aisles")
                    }
                
                AllMedicinesView()
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("All Medicines")
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        session.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
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
