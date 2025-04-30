import Foundation

class UserAPIService {
    static let shared = UserAPIService()

    private init() {}

    func login(username: String, password: String, completion: @escaping (Bool, String?, Int?) -> Void) {
        guard let url = URL(string: "\(SERVER_URL)/api/login") else {
            completion(false, "Invalid URL", nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "username": username,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(false, "JSON serialization failed", nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Request failed: \(error.localizedDescription)", nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let success = json["success"] as? Bool, success,
                       let userObject = json["user"] as? [String: Any] {
                        
                        let userId = userObject["id"] as? Int ?? userObject["user_id"] as? Int ?? 0
                        
                        if userId == 0 {
                            completion(false, "Invalid user ID", nil)
                            return
                        }
                        
                        completion(true, nil, userId)
                    } else {
                        completion(false, "Failed to parse response", nil)
                    }
                } else {
                    completion(false, "Login failed", nil)
                }
            } else {
                completion(false, "Login failed", nil)
            }
        }.resume()
    }

    func fetchUser(userId: Int, completion: @escaping (User?) -> Void) {
        if userId <= 0 {
            completion(nil)
            return
        }
        
        let urlString = "\(SERVER_URL)/api/user/\(userId)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data,
                       let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let success = jsonObject["success"] as? Bool, success,
                       let json = jsonObject["user"] as? [String: Any] {
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let dobString = json["dob"] as? String ?? ""
                        let dob = dateFormatter.date(from: dobString) ?? Date()
                        
                        let currentYear = Calendar.current.component(.year, from: Date())
                        
                        let user_id = json["user_id"] as? Int ?? json["id"] as? Int ?? userId
                        
                        let username = json["username"] as? String
                        let email = json["email"] as? String ?? ""
                        let finalUsername = (username != nil && !username!.isEmpty) ? username! : email
                        
                        let user = User(
                            firstName: json["firstName"] as? String ?? "",
                            lastName: json["lastName"] as? String ?? "",
                            username: finalUsername,
                            joinedYear: json["joinedYear"] as? String ?? "\(currentYear)",
                            image: nil,
                            gender: json["gender"] as? String ?? "",
                            dob: dob,
                            phone: json["phone"] as? String ?? "",
                            email: email,
                            user_id: user_id,
                            avatarPath: json["avatar_path"] as? String ?? json["avatarPath"] as? String,
                            password: json["password"] as? String ?? ""
                        )
                        completion(user)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }

    func updateUser(user: User, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(SERVER_URL)/api/user/\(user.user_id)") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dobString = dateFormatter.string(from: user.dob)

        let userData: [String: Any] = [
            "firstName": user.firstName,
            "lastName": user.lastName,
            "gender": user.gender,
            "dob": dobString,
            "phone": user.phone,
            "email": user.email,
            "username": user.username,
            "joinedYear": user.joinedYear,
            "password": user.password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch {
            completion(false, "JSON serialization failed")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Request failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(true, nil)
                } else {
                    completion(false, "Failed to update user information")
                }
            } else {
                completion(false, "Failed to update user information")
            }
        }.resume()
    }

    func updatePassword(userId: Int, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(SERVER_URL)/api/user/\(userId)/updatePassword") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "newPassword": newPassword
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(false, "JSON serialization failed")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Request failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(true, nil)
                } else {
                    completion(false, "Failed to update password")
                }
            } else {
                completion(false, "Failed to update password")
            }
        }.resume()
    }
}
