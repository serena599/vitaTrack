import SwiftUI
import Foundation

class HomepageViewModel: ObservableObject {
    @Published var totalProgress: Double = 0.0
    @Published var selectedDate: Date = Date()
    @Published var showDatePicker: Bool = false
    @Published var currentGoals: (vegetables: String, fruits: String, grains: String, meat: String, dairy: String, extras: String) = ("0", "0", "0", "0", "0", "0")
    @Published var networkError: String? = nil
    
    var motivationalMessage: String {
        switch totalProgress {
        case 0.0..<0.2:
            return "Start your day with purpose! Every step counts on your journey to better health."
        case 0.2..<0.4:
            return "You're making great progress! Keep moving forward and remember that consistency leads to results."
        case 0.4..<0.6:
            return "You're halfway there! Your dedication is truly inspiring. Push through these next steps."
        case 0.6..<0.8:
            return "You're almost there! Keep up the great work and stay motivated."
        case 0.8..<1.0:
            return "So close to the finish line! Perseverance is the key to success."
        case 1.0:
            return "Congratulations on achieving your goal today! Celebrate this win!"
        default:
            return "Keep pushing forward!"
        }
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    // Base URL for server
    private let baseURL = SERVER_URL
    
    // Fetch nutrition progress from the backend using the updated API
    func fetchNutritionProgress(for date: Date, userId: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        guard let url = URL(string: "\(baseURL)/api/nutrition_progress?userId=\(userId)&date=\(dateString)") else {
            networkError = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Error handling
            if let error = error {
                DispatchQueue.main.async {
                    self.networkError = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.networkError = "Server error: Invalid response"
                }
                return
            }
            
            // Parse data
            guard let data = data else {
                DispatchQueue.main.async {
                    self.networkError = "No data received"
                }
                return
            }
            
            do {
                // Parse JSON response
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let dataDict = json["data"] as? [String: Any],
                      let categories = dataDict["categories"] as? [[String: Any]] else {
                    throw NSError(domain: "JSONParsing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                }
                
                // Extract total progress
                let totalProgress = (dataDict["totalProgress"] as? Double) ?? 0.0
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    // Update total progress
                    self.totalProgress = totalProgress
                    
                    // Update current goals from categories
                    self.updateCurrentGoals(from: categories)
                }
            } catch {
                DispatchQueue.main.async {
                    self.networkError = "Parsing error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // Helper method to update current goals from API response
    private func updateCurrentGoals(from categories: [[String: Any]]) {
        // Create a dictionary to map category names to their goal values
        var goalsDict: [String: String] = [:]
        
        for category in categories {
            guard let name = category["name"] as? String,
                  let goalValue = category["goalValue"] as? Double else {
                continue
            }
            
            // Convert goal value to string with one decimal place
            goalsDict[name.lowercased()] = String(format: "%.1f", goalValue)
        }
        
        // Update currentGoals using the mapped dictionary
        self.currentGoals = (
            vegetables: goalsDict["vegetables"] ?? "5.0",
            fruits: goalsDict["fruit"] ?? "2.0",
            grains: goalsDict["grains"] ?? "5.0",
            meat: goalsDict["meat"] ?? "2.5",
            dairy: goalsDict["dairy"] ?? "2.5",
            extras: goalsDict["extras"] ?? "0.5"
        )
    }
    
    // Load user's goal settings from the backend
    func loadGoalSettings(userId: Int) {
        guard let url = URL(string: "\(baseURL)/api/goal_settings?userId=\(userId)") else {
            networkError = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Error handling
            if let error = error {
                DispatchQueue.main.async {
                    self.networkError = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.networkError = "Server error: Invalid response"
                }
                return
            }
            
            // Parse data
            guard let data = data else {
                DispatchQueue.main.async {
                    self.networkError = "No data received"
                }
                return
            }
            
            do {
                // Parse JSON
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    throw NSError(domain: "JSONParsing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
                }
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    // Update current goals with formatted values
                    self.currentGoals = (
                        vegetables: String(format: "%.1f", (json["vegetables"] as? Double) ?? 5.0),
                        fruits: String(format: "%.1f", (json["fruits"] as? Double) ?? 2.0),
                        grains: String(format: "%.1f", (json["grains"] as? Double) ?? 5.0),
                        meat: String(format: "%.1f", (json["meat"] as? Double) ?? 2.5),
                        dairy: String(format: "%.1f", (json["dairy"] as? Double) ?? 2.5),
                        extras: String(format: "%.1f", (json["extras"] as? Double) ?? 0.5)
                    )
                    self.networkError = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.networkError = "Parsing error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
