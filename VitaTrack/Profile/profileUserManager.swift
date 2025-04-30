import SwiftUI
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var lastError: String?
    @Published var isLoading: Bool = false

    private let userAPIService = UserAPIService.shared
    private let avatarService = AvatarService.shared
    private let userIdKey = "savedUserId"

    init() {
        if let savedUserId = UserDefaults.standard.object(forKey: userIdKey) as? Int {
            isLoading = true
            
            self.fetchUser(userId: savedUserId) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if self.currentUser != nil {
                        self.isLoggedIn = true
                    } else {
                        let tempUser = User(
                            firstName: "Temp",
                            lastName: "User\(savedUserId)",
                            username: "user\(savedUserId)",
                            joinedYear: "2023",
                            image: nil,
                            gender: "",
                            dob: Date(),
                            phone: "",
                            email: "user\(savedUserId)@example.com",
                            user_id: savedUserId,
                            avatarPath: nil,
                            password: ""
                        )
                        self.currentUser = tempUser
                        self.isLoggedIn = true
                    }
                    
                    self.objectWillChange.send()
                }
            }
        }
    }

    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.isLoggedIn = false
            self.currentUser = nil
            self.objectWillChange.send()
        }
        
        userAPIService.login(username: username, password: password) { success, message, userId in
            if success, let userId = userId {
                UserDefaults.standard.set(userId, forKey: self.userIdKey)
                UserDefaults.standard.synchronize()
                
                self.fetchUser(userId: userId) {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        
                        if self.currentUser != nil {
                            self.isLoggedIn = true
                            self.objectWillChange.send()
                            
                            // Send user login notification
                            NotificationCenter.default.post(name: Notification.Name("UserDidLoginNotification"), object: nil)
                            print("User logged in: ID = \(userId), sending login notification")
                            
                            completion(true, nil)
                        } else {
                            let tempUser = User(
                                firstName: "Temp",
                                lastName: "User",
                                username: username,
                                joinedYear: "2023",
                                image: nil,
                                gender: "",
                                dob: Date(),
                                phone: "",
                                email: username,
                                user_id: userId,
                                avatarPath: nil,
                                password: password
                            )
                            self.currentUser = tempUser
                            self.isLoggedIn = true
                            self.objectWillChange.send()
                            
                            // Also send notification
                            NotificationCenter.default.post(name: Notification.Name("UserDidLoginNotification"), object: nil)
                            print("Temp user logged in: ID = \(userId), sending login notification")
                            
                            completion(true, nil)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.lastError = message
                    self.isLoggedIn = false
                    self.objectWillChange.send()
                    completion(false, message)
                }
            }
        }
    }

    func fetchUser(userId: Int, completion: (() -> Void)? = nil) {
        userAPIService.fetchUser(userId: userId) { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.currentUser = user
                    
                    // Ensure login status is set to true
                    self.isLoggedIn = true
                    
                    // Ensure user ID is saved to UserDefaults
                    UserDefaults.standard.set(userId, forKey: self.userIdKey)
                    UserDefaults.standard.synchronize()
                    
                    self.objectWillChange.send()
                    
                    if let avatarPath = user.avatarPath {
                        self.avatarService.loadAvatar(from: avatarPath) { image in
                            DispatchQueue.main.async {
                                self.currentUser?.image = image
                                self.objectWillChange.send()
                                completion?()
                            }
                        }
                    } else {
                        completion?()
                    }
                } else {
                    self.objectWillChange.send()
                    completion?()
                }
            }
        }
    }

    func updateUserInfo(newUser: User) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.objectWillChange.send()
        }
        
        userAPIService.updateUser(user: newUser) { success, message in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    self.fetchUser(userId: newUser.user_id)
                } else {
                    self.lastError = message
                    self.objectWillChange.send()
                }
            }
        }
    }

    func uploadAvatar(image: UIImage) {
        guard let userId = currentUser?.user_id else {
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.objectWillChange.send()
        }
        
        avatarService.uploadAvatar(image: image, userId: userId) { avatarUrl in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let avatarUrl = avatarUrl {
                    self.currentUser?.avatarPath = avatarUrl
                    self.avatarService.loadAvatar(from: avatarUrl) { image in
                        DispatchQueue.main.async {
                            self.currentUser?.image = image
                            self.objectWillChange.send()
                        }
                    }
                } else {
                    self.objectWillChange.send()
                }
            }
        }
    }

    func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let userId = currentUser?.user_id else {
            completion(false, "User not logged in")
            return
        }

        if currentPassword != currentUser?.password {
            completion(false, "Current password is incorrect")
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.objectWillChange.send()
        }
        
        userAPIService.updatePassword(userId: userId, newPassword: newPassword) { success, message in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    self.currentUser?.password = newPassword
                }
                self.objectWillChange.send()
                completion(success, message)
            }
        }
    }

    func logout() {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn = false
            UserDefaults.standard.removeObject(forKey: self.userIdKey)
            UserDefaults.standard.synchronize()
            self.objectWillChange.send()
            
            // Send user logout notification
            NotificationCenter.default.post(name: Notification.Name("UserDidLogoutNotification"), object: nil)
            print("User logged out, sending logout notification")
        }
    }
}
