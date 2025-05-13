import SwiftUI


struct inputField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .padding()
                .autocapitalization(.none)
                .keyboardType(.asciiCapable)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
    }
}


struct secureInputField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    @State private var isSecured: Bool = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)
            
            if isSecured {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .padding()
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .padding()
                    .autocapitalization(.none)
            }
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye" : "eye.slash")
                    .foregroundColor(.white)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
    }
}

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = SignUpViewModel()
    @State private var privacyPolicyAccepted = false
    @State private var showPrivacyPolicy = false
    
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
                        
                        
                        HStack {
                            Button(action: {
                                privacyPolicyAccepted.toggle()
                            }) {
                                Image(systemName: privacyPolicyAccepted ? "checkmark.square.fill" : "square")
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                            }
                            
                            Text("I agree to the ")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            
                            Button(action: {
                                showPrivacyPolicy = true
                            }) {
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                    .underline()
                                    .font(.system(size: 14))
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        if !privacyPolicyAccepted {
                            viewModel.errorMessage = "You must agree to the Privacy Policy to continue"
                            viewModel.showError = true
                            return
                        }
                        
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
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .onChange(of: viewModel.isSignUpSuccessful) { success in
            if success {
                dismiss()
            }
        }
    }
}


struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Text("Last Updated: May 13, 2025")
                        .font(.subheadline)
                        .padding(.bottom, 20)
                    
                    policySection(title: "1. Information We Collect", content: "VitaTrack collects personal data such as your name, email address, date of birth, and information about your diet and health preferences. We also collect usage data to improve our services.")
                    
                    policySection(title: "2. How We Use Your Information", content: "We use your information to provide and improve our services, personalize your experience, communicate with you, and comply with legal obligations.")
                    
                    policySection(title: "3. Data Security", content: "We implement appropriate security measures to protect your personal data from unauthorized access, alteration, disclosure, or destruction.")
                    
                    policySection(title: "4. Your Rights", content: "You have the right to access, correct, update, or request deletion of your personal information. You can also object to processing of your personal information or request portability.")
                    
                    policySection(title: "5. Changes to This Policy", content: "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.")
                    
                    policySection(title: "6. Cookies and Tracking", content: "We use cookies and similar tracking technologies to track activity on our Service and hold certain information. Cookies are files with a small amount of data which may include an anonymous unique identifier.")
                    
                    policySection(title: "7. Service Providers", content: "We may employ third-party companies and individuals to facilitate our Service, provide the Service on our behalf, perform Service-related services, or assist us in analyzing how our Service is used.")
                    
                    policySection(title: "8. Analytics", content: "We may use third-party Service Providers to monitor and analyze the use of our Service.")
                    
                    policySection(title: "9. Children's Privacy", content: "Our Service does not address anyone under the age of 18. We do not knowingly collect personally identifiable information from anyone under the age of 18.")
                    
                    policySection(title: "10. Contact Us", content: "If you have any questions about this Privacy Policy, please contact us at privacy@vitatrack.com")
                    
                    Spacer().frame(height: 50)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationBarTitle("Privacy Policy", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(UserManager.shared)
    }
}

