import SwiftUI

struct AppView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var foodViewModel = FoodViewModel()
    @StateObject var homepageViewModel = HomepageViewModel()
    
    var body: some View {
        if userManager.isLoggedIn {
            ContentView()
                .environmentObject(userManager)
                .environmentObject(foodViewModel)
                .environmentObject(homepageViewModel)
        } else {
            LoginView()
                .environmentObject(userManager)
                .environmentObject(foodViewModel)
                .environmentObject(homepageViewModel)
        }
    }
}

#Preview {
    AppView()
        .environmentObject(HomepageViewModel())
}
 
