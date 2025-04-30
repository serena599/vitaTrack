import SwiftUI

// Setting view
struct Setting: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager
    
    @State private var showResetPassword = false
    
    // For GoalSetting reminder menu popup
    @State private var showGoalReminder = false
    
    // Receive HomepageViewModel instance from profileView
    @EnvironmentObject var homepageViewModel: HomepageViewModel

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(action: {
                        showResetPassword = true
                    }) {
                        Text("Reset Password")
                            .foregroundColor(.black)
                    }
                    .sheet(isPresented: $showResetPassword) {
                        ResetPasswordView()
                            .environmentObject(userManager)
                    }
                    .padding(.vertical, 8)
                    
                    // GoalSetting reminder setup
                    Button(action: {
                        showGoalReminder = true
                    }) {
                        Text("Notification Setup")
                            .foregroundColor(.black)
                    }
                    .sheet(isPresented: $showGoalReminder) {
                        NotificationView()
                            .environmentObject(userManager)
                            .environmentObject(homepageViewModel)
                    }
                    .padding(.vertical, 8)

                    Button(action: {
                        userManager.logout()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Logout")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.foodPrimary)
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
