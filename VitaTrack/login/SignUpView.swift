//
//  SignUpView.swift
//  myfoodchoice
//
//  Created by serena on 17/2/2025.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        ZStack {
            Color.loginGreen
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("VitaTrack")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .white, radius: 1)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                
                ScrollView {
                    VStack(spacing: 15) {
                        InputField(icon: "person", placeholder: "Username", text: $viewModel.username)
                        InputField(icon: "person.text.rectangle", placeholder: "First Name", text: $viewModel.firstName)
                        InputField(icon: "person.text.rectangle.fill", placeholder: "Last Name", text: $viewModel.lastName)
                        InputField(icon: "calendar", placeholder: "Date of Birth (DD-MM-YYYY)", text: $viewModel.dobString)
                        InputField(icon: "envelope", placeholder: "Email", text: $viewModel.email)
                        InputField(icon: "phone", placeholder: "Phone", text: $viewModel.phone)
                        SecureInputField(icon: "lock", placeholder: "Password", text: $viewModel.password)
                        SecureInputField(icon: "lock", placeholder: "Confirm Password", text: $viewModel.confirmPassword)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            await viewModel.signUp()
                        }
                    }) {
                        ZStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.33, green: 0.69, blue: 0.33)))
                            } else {
                                Text("SIGN UP")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.33, green: 0.69, blue: 0.33))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 50)
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .alert(viewModel.errorMessage, isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: viewModel.isSignUpSuccessful) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(UserManager.shared)
    }
}
