import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = LoginViewModel()
    @State private var showSignUp = false
    @State private var showAlert = false
    @State private var showmainView = false
    
    //
    @EnvironmentObject var homeViewModel: HomepageViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.foodPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    Text("VitaTrack")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                        .padding(.top, 110)
                        .padding(.bottom, 200)

                    VStack(spacing: 25) {
                        
                        //username
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                            TextField("USERNAME", text: $viewModel.username)
                                .foregroundColor(.white)
                                .accentColor(.white)
                        }
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        
                        // Password
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                            SecureField("Password", text: $viewModel.password)
                                .foregroundColor(.white)
                                .accentColor(.white)
                        }
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        
                        // login
                        Button(action: {
                            if !viewModel.isLoading {
                                viewModel.isLoading = true
                                viewModel.login { success in
                                    if success {
                                        showmainView = true
                                    } else {
                                        showAlert = true
                                    }
                                    viewModel.isLoading = false
                                }
                            }
                        }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("LOGIN")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.foodPrimary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(viewModel.isLoading ? Color.gray : Color.white)
                            .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .animation(.easeInOut, value: viewModel.isLoading)

                        // Button
                        HStack {
                            Button("Sign up") {
                                showSignUp = true
                            }
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button("Forgot password?") {
                                //
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 2)
                        
                        Spacer()
                    }
                }
            }
            .navigationDestination(isPresented: $showmainView) {
                ContentView()
                    .environmentObject(userManager)
                    .navigationBarBackButtonHidden(true)
                    .environmentObject(homeViewModel)
            }
            
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(userManager)
            }
            .alert("Login Failed", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Invalid username or password")
            }
        }
        .onAppear {
            viewModel.userManager = userManager
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserManager())
        .environmentObject(HomepageViewModel())
}

