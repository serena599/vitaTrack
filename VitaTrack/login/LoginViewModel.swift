import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var userId: Int = 0
    
    var userManager: UserManager
    
    var onLoginSuccess: (() -> Void)?
    
    init(userManager: UserManager = UserManager.shared) {
        self.userManager = userManager
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        userManager.login(username: username, password: password) { success, message in
            DispatchQueue.main.async {
                if success {
                    self.userId = self.userManager.currentUser?.user_id ?? 0
                    self.isLoggedIn = true
                    self.onLoginSuccess?()
                } else {
                    self.errorMessage = message
                }
                
                completion(success)
            }
        }
    }
    
    func logout() {
        userManager.logout()
        isLoggedIn = false
        userId = 0
    }
}
