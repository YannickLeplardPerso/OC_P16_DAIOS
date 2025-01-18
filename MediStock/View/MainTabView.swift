import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var medicineStore: MedicineStockViewModel
    
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
                        medicineStore.addRandomMedicine(user: session.session?.uid ?? "")
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
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
