//
//  FavoriteManager.swift
//  VitaTrack
//
//  Created by AI Assistant on 13/03/2025.
//

import Foundation
import Combine

// User favorite data model
struct FavoriteRecipe: Identifiable, Codable {
    let id: Int
    var user_id: Int
    var recipe_ID: Int
}

// Class for managing user favorites
class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    @Published var currentUserID: Int = 0
    @Published var userFavorites: [Int] = [] // Store the list of recipe IDs favorited by the current user
    
    private init() {

        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(userDidLogin),
            name: Notification.Name("UserDidLoginNotification"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(userDidLogout),
            name: Notification.Name("UserDidLogoutNotification"),
            object: nil
        )
        
     
        if let user = UserManager.shared.currentUser {
            self.currentUserID = user.user_id
            fetchUserFavorites()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func userDidLogin() {
        if let user = UserManager.shared.currentUser {
            let userID = user.user_id
            print("FavoriteManager: User logged in, updating current user ID from \(self.currentUserID) to \(userID)")
            
            if userID <= 0 {
                print("FavoriteManager: Warning - received invalid user ID after login: \(userID)")
                return
            }
            
            self.currentUserID = userID
            print("FavoriteManager: User logged in, updated current user ID to \(self.currentUserID)")
            fetchUserFavorites()
        } else {
            print("FavoriteManager: User login notification received but no current user found")
        }
    }
    
    @objc private func userDidLogout() {
        self.currentUserID = 0
        self.userFavorites = []
        print("FavoriteManager: User logged out, cleared favorites list")
    }
    
    func setCurrentUser(userID: Int) {
        print("FavoriteManager: Setting current user ID to \(userID)")
        
        if userID <= 0 {
            print("FavoriteManager: Warning - invalid user ID: \(userID)")
            return
        }
        
        self.currentUserID = userID
        print("FavoriteManager: Current user ID updated to \(userID)")
        
        // Fetch updated favorite list
        fetchUserFavorites { success in
            if success {
                print("FavoriteManager: Successfully fetched favorites for user \(userID)")
            } else {
                print("FavoriteManager: Failed to fetch favorites for user \(userID)")
            }
        }
    }
    
    func fetchUserFavorites(completion: @escaping (Bool) -> Void = {_ in}) {
        // Get user's favorite list from server
        guard currentUserID > 0 else {
            completion(false)
            return
        }
        guard let url = URL(string: "\(SERVER_URL)/api/favorites/\(currentUserID)") else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                let favorites = try JSONDecoder().decode([FavoriteRecipe].self, from: data)
                DispatchQueue.main.async {
                    self.userFavorites = favorites.map { $0.recipe_ID }
                    print("✅ Successfully retrieved user favorites, total: \(self.userFavorites.count)")
                    completion(true)
                }
            } catch {
                print("❌ Failed to parse user favorites:", error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func toggleFavorite(recipeID: Int, completion: @escaping (Bool) -> Void = {_ in}) {
        guard currentUserID > 0 else {
            completion(false)
            return
        }
        
        if userFavorites.contains(recipeID) {
            removeFavorite(recipeID: recipeID, completion: completion)
        } else {
            addFavorite(recipeID: recipeID, completion: completion)
        }
    }
    
    private func addFavorite(recipeID: Int, completion: @escaping (Bool) -> Void = {_ in}) {
        guard let url = URL(string: "\(SERVER_URL)/api/favorites/add") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_id": currentUserID, "recipe_ID": recipeID] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    if !self.userFavorites.contains(recipeID) {
                        self.userFavorites.append(recipeID)
                    }
                    print("✅ Successfully added to favorites")
                    completion(true)
                }
            } else {
                print("❌ Failed to add favorite:", error?.localizedDescription ?? "")
                completion(false)
            }
        }.resume()
    }
    
    private func removeFavorite(recipeID: Int, completion: @escaping (Bool) -> Void = {_ in}) {
        guard let url = URL(string: "\(SERVER_URL)/api/favorites/remove") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_id": currentUserID, "recipe_ID": recipeID] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.userFavorites.removeAll { $0 == recipeID }
                    print("✅ Successfully removed from favorites")
                    completion(true)
                }
            } else {
                print("❌ Failed to remove favorite:", error?.localizedDescription ?? "")
                completion(false)
            }
        }.resume()
    }
    
    func isFavorite(recipeID: Int) -> Bool {
        return userFavorites.contains(recipeID)
    }
}