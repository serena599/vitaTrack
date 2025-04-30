import SwiftUI

// Reset password view
struct ResetPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false

    var body: some View {
        NavigationView {
            Form {
                Section(" ") {
                    // Current Password
                    HStack {
                        if showCurrentPassword {
                            TextField("Current Password", text: $currentPassword)
                        } else {
                            SecureField("Current Password", text: $currentPassword)
                        }
                        Button(action: {
                            showCurrentPassword.toggle()
                        }) {
                            Image(systemName: showCurrentPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)

                    // New Password
                    HStack {
                        if showNewPassword {
                            TextField("New Password", text: $newPassword)
                        } else {
                            SecureField("New Password", text: $newPassword)
                        }
                        Button(action: {
                            showNewPassword.toggle()
                        }) {
                            Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)

                    // Confirm New Password
                    HStack {
                        if showConfirmPassword {
                            TextField("Confirm New Password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm New Password", text: $confirmPassword)
                        }
                        Button(action: {
                            showConfirmPassword.toggle()
                        }) {
                            Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    Button(action: {
                        // Check if new password and confirm password match
                        if newPassword != confirmPassword {
                            errorMessage = "New password and confirm password do not match"
                            showAlert = true
                            return
                        }

                        // Call the updatePassword method
                        userManager.updatePassword(currentPassword: currentPassword, newPassword: newPassword) { success, message in
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                errorMessage = message
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.foodPrimary)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// Preview for reset password view
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
            .environmentObject(UserManager())
    }
}

