import Foundation

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dobString = ""
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isSignUpSuccessful = false
    
    func signUp() {
        // Basic validation
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        // Validate date format and convert to YYYY-MM-DD
        guard let formattedDate = convertAndValidateDate(dobString) else {
            errorMessage = "Please enter date in DD-MM-YYYY format"
            showError = true
            return
        }
        
        isLoading = true
        
        // Prepare request data
        let signUpData: [String: Any] = [
            "username": username,
            "email": email,
            "phone": phone,
            "password": password,
            "firstName": firstName.isEmpty ? username : firstName,
            "lastName": lastName,
            "dob": formattedDate
        ]
        
        guard let url = URL(string: "\(SERVER_URL)/api/signup"),
              let jsonData = try? JSONSerialization.data(withJSONObject: signUpData) else {
            isLoading = false
            errorMessage = "Failed to prepare data"
            showError = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    if httpResponse.statusCode == 200 {
                        if let success = json["success"] as? Bool, success {
                            isSignUpSuccessful = true
                            errorMessage = "Registration successful! Please login with your new account"
                            showError = true
                        } else {
                            errorMessage = message
                            showError = true
                        }
                    } else {
                        errorMessage = message
                        showError = true
                    }
                } else {
                    errorMessage = "Invalid server response format"
                    showError = true
                }
            } catch {
                errorMessage = "Registration failed: \(error.localizedDescription)"
                showError = true
            }
            
            isLoading = false
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func convertAndValidateDate(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        // First try to parse the input date
        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }
        
        // Check if the date is not in the future
        guard date <= Date() else {
            return nil
        }
        
        // Convert to YYYY-MM-DD format for the server
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        return outputFormatter.string(from: date)
    }
} 
