//
//  GoalTrackingView.swift
//  MyFoodChoice
//
//  Created by CHIHCHEN on 2024/12/14.
//

import SwiftUI
import Foundation

struct GoalTrackingView: View {
    @State private var selectedDate = Date()
    @State private var progressData: [GoalProgress] = []
    @State private var isCalendarVisible = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @EnvironmentObject private var userManager: UserManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { goToPreviousDay() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                
                Text(dateString)
                    .font(.headline)
                
                Button(action: { goToNextDay() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(progressData) { progress in
                            GoalProgressRow(progress: progress)
                        }
                    }
                    .padding()
                }
            }
        
            
            if isCalendarVisible {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .onChange(of: selectedDate) { _ in
                        fetchProgressData(for: selectedDate)
                        isCalendarVisible = false
                    }
            }
        }
        .onAppear {
            if userManager.isLoggedIn {
                fetchProgressData(for: selectedDate)
            }
        }
        .onChange(of: userManager.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                fetchProgressData(for: selectedDate)
            } else {
                progressData = []
                errorMessage = "Please log in to view your progress"
            }
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    private func goToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
            fetchProgressData(for: newDate)
        }
    }
    
    private func goToNextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = newDate
            fetchProgressData(for: newDate)
        }
    }
    
    func fetchProgressData(for date: Date) {
        guard let userId = userManager.currentUser?.user_id else {
            errorMessage = "Please log in to view your progress"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        fetchGoalSettings(userId: userId) { goalSettings in
            self.fetchDailyIntake(userId: userId, date: dateString) { dailyIntake in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if goalSettings.vegetables == 0 && goalSettings.fruits == 0 && goalSettings.grains == 0 {
                        self.errorMessage = "Please set your nutrition goals first"
                        return
                    }
                    
                    self.progressData = [
                        GoalProgress(
                            category: "Vegetables",
                            icon: "leaf.fill",
                            progress: min(dailyIntake.vegetables / max(goalSettings.vegetables, 1), 1.0),
                            serves: String(format: "%.1f / %.1f serves", dailyIntake.vegetables, goalSettings.vegetables)
                        ),
                        GoalProgress(
                            category: "Fruit",
                            icon: "apple.logo",
                            progress: min(dailyIntake.fruits / max(goalSettings.fruits, 1), 1.0),
                            serves: String(format: "%.1f / %.1f serves", dailyIntake.fruits, goalSettings.fruits)
                        ),
                        GoalProgress(
                            category: "Grains",
                            icon: "bag.fill",
                            progress: min(dailyIntake.grains / max(goalSettings.grains, 1), 1.0),
                            serves: String(format: "%.1f / %.1f serves", dailyIntake.grains, goalSettings.grains)
                        ),
                        GoalProgress(
                            category: "Meat",
                            icon: "fish.fill",
                            progress: min(dailyIntake.meat / max(goalSettings.meat, 1), 1.0),
                            serves: String(format: "%.1f / %.1f serves", dailyIntake.meat, goalSettings.meat)
                        ),
                        GoalProgress(
                            category: "Dairy",
                            icon: "drop.fill",
                            progress: min(dailyIntake.dairy / max(goalSettings.dairy, 1), 1.0),
                            serves: String(format: "%.1f / %.1f serves", dailyIntake.dairy, goalSettings.dairy)
                        ),
                        GoalProgress(
                            category: "Extras",
                            icon: "flame.fill",
                            progress: min(dailyIntake.extras / max(goalSettings.extras, 1), 1.0),
                            serves: String(format: "%.1f / %.1f serves", dailyIntake.extras, goalSettings.extras)
                        )
                    ]
                }
            }
        }
    }
    
    func fetchDailyIntake(userId: Int, date: String, completion: @escaping ((vegetables: Double, fruits: Double, grains: Double, meat: Double, dairy: Double, extras: Double)) -> Void) {
        guard let url = URL(string: "\(SERVER_URL)/api/daily_intake?userId=\(userId)&date=\(date)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid request URL"
                self.isLoading = false
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network request failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid server response"
                    self.isLoading = false
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid JSON format"
                        self.isLoading = false
                    }
                    return
                }
                
                let vegetables = (json["vegetables"] as? NSNumber)?.doubleValue ?? 0
                let fruits = (json["fruits"] as? NSNumber)?.doubleValue ?? 0
                let grains = (json["grains"] as? NSNumber)?.doubleValue ?? 0
                let meat = (json["meat"] as? NSNumber)?.doubleValue ?? 0
                let dairy = (json["dairy"] as? NSNumber)?.doubleValue ?? 0
                let extras = (json["extras"] as? NSNumber)?.doubleValue ?? 0
                
                completion((vegetables, fruits, grains, meat, dairy, extras))
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse server response"
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    func fetchGoalSettings(userId: Int, completion: @escaping ((vegetables: Double, fruits: Double, grains: Double, meat: Double, dairy: Double, extras: Double)) -> Void) {
        guard let url = URL(string: "\(SERVER_URL)/api/goal_settings?userId=\(userId)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch goal settings"
                    self.isLoading = false
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    print("Goal settings response: \(json)")
                    
                    let vegetables = Double(json["vegetables"] ?? "0.0") ?? 0.0
                    let fruits = Double(json["fruits"] ?? "0.0") ?? 0.0
                    let grains = Double(json["grains"] ?? "0.0") ?? 0.0
                    let meat = Double(json["meat"] ?? "0.0") ?? 0.0
                    let dairy = Double(json["dairy"] ?? "0.0") ?? 0.0
                    let extras = Double(json["extras"] ?? "0.0") ?? 0.0
                    
                    completion((vegetables, fruits, grains, meat, dairy, extras))
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse goal settings"
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse goal settings"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

struct GoalProgressRow: View {
    var progress: GoalProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: progress.icon)
                    .foregroundColor(.green)
                
                Text(progress.category)
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(progress.progress * 100))% Completed")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            Text(progress.serves)
                .font(.footnote)
                .foregroundColor(.gray)
            
            ProgressView(value: progress.progress)
                .tint(progress.progress >= 1.0 ? Color.customPink : Color.loginGreen)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct GoalProgress: Identifiable {
    let id = UUID()
    var category: String
    var icon: String
    var progress: Double
    var serves: String
}

#Preview {
    GoalTrackingView()
        .environmentObject(UserManager())
}
