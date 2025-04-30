import SwiftUI
import Foundation

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var serverId: Int?
    var recordId: Int?
    var name: String
    var calories: Int
    var unit: String
    var amount: Double?
    var mealType: MealType?
    var date: Date
    var imageUrl: String?
    var addFoodCategory: AddFoodCategory?
    
    enum CodingKeys: String, CodingKey {
        case id = "local_id"
        case serverId = "db_id"
        case recordId = "record_id"
        case name
        case calories
        case unit
        case amount
        case mealType
        case date
        case imageUrl = "image_url"
        case addFoodCategory = "food_category"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = UUID()
        serverId = try? container.decode(Int.self, forKey: .serverId)
        recordId = try? container.decode(Int.self, forKey: .recordId)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Int.self, forKey: .calories)
        unit = try container.decode(String.self, forKey: .unit)
        amount = try? container.decodeIfPresent(Double.self, forKey: .amount)
        mealType = try? container.decodeIfPresent(MealType.self, forKey: .mealType)
        date = try container.decode(Date.self, forKey: .date)
        imageUrl = try? container.decodeIfPresent(String.self, forKey: .imageUrl)
        addFoodCategory = try? container.decodeIfPresent(AddFoodCategory.self, forKey: .addFoodCategory)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(serverId, forKey: .serverId)
        try container.encodeIfPresent(recordId, forKey: .recordId)
        try container.encode(name, forKey: .name)
        try container.encode(calories, forKey: .calories)
        try container.encode(unit, forKey: .unit)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encodeIfPresent(mealType, forKey: .mealType)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(addFoodCategory, forKey: .addFoodCategory)
    }
    
    init(id: UUID = UUID(),
         serverId: Int? = nil,
         recordId: Int? = nil,
         name: String,
         calories: Int,
         unit: String = "serving",
         amount: Double? = nil,
         mealType: MealType? = nil,
         date: Date,
         imageUrl: String? = nil,
         addFoodCategory: AddFoodCategory? = nil) {
        self.id = id
        self.serverId = serverId
        self.recordId = recordId
        self.name = name
        self.calories = calories
        self.unit = unit
        self.amount = amount
        self.mealType = mealType
        self.date = date
        self.imageUrl = imageUrl
        self.addFoodCategory = addFoodCategory
    }
}

struct APIResponse<T: Codable>: Codable {
    let message: String
    let data: T
}

struct MealRecordResponse: Codable {
    let id: String
    let food_id: Int
    let name: String
    let calories: Int
    let unit: String
    let amount: Double
    let meal_type: String
    let record_date: String
    let image_url: String?
    let food_category: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case food_id
        case name
        case calories
        case unit
        case amount
        case meal_type
        case record_date
        case image_url
        case food_category
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "\(SERVER_URL)/api"
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }()
    
    let serverBaseUrl = SERVER_URL
    
    func getAllFoods() async throws -> [FoodItem] {
        guard let url = URL(string: "\(baseURL)/foods") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let foodsData = json["data"] as? [[String: Any]] {
            
            return try foodsData.map { foodDict in
                let processedDict: [String: Any] = [
                    "name": foodDict["name"] as? String ?? "",
                    "calories": foodDict["calories"] as? Int ?? 0,
                    "unit": foodDict["unit"] as? String ?? "serving"
                ]
                
                let foodData = try JSONSerialization.data(withJSONObject: processedDict)
                return try decoder.decode(FoodItem.self, from: foodData)
            }
        }
        throw URLError(.badServerResponse)
    }
    
    func addFood(_ food: FoodItem) async throws -> Int {
        guard let url = URL(string: "\(baseURL)/foods") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let foodData: [String: Any] = [
            "name": food.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "calories": food.calories,
            "unit": food.unit.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: foodData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let responseData = json["data"] as? [String: Any],
           let id = responseData["id"] as? Int {
            return id
        }
        
        throw URLError(.badServerResponse)
    }
    
    func getMealRecords(userId: Int, date: Date? = nil, mealType: MealType? = nil) async throws -> [FoodItem] {
        guard userId > 0 else {
            debugPrint("Error: Invalid user ID")
            throw URLError(.badURL)
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/meal-records/\(userId)")!
        var queryItems: [URLQueryItem] = []
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(URLQueryItem(name: "date", value: formatter.string(from: date)))
        }
        
        if let mealType = mealType {
            queryItems.append(URLQueryItem(name: "meal_type", value: mealType.rawValue))
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            debugPrint("Error: Invalid URL")
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            debugPrint("Error: Invalid response")
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            debugPrint("Error: Server returned \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        let apiResponse = try decoder.decode(APIResponse<[MealRecordResponse]>.self, from: data)
        
        return apiResponse.data.map { record in
            var imageUrl: String? = nil
            if let recordImageUrl = record.image_url, !recordImageUrl.isEmpty {
                if recordImageUrl.hasPrefix("http://") || recordImageUrl.hasPrefix("https://") {
                    imageUrl = recordImageUrl
                } else {
                    imageUrl = "\(serverBaseUrl)\(recordImageUrl)"
                }
            }
            
            return FoodItem(
                id: UUID(),
                serverId: record.food_id,
                recordId: record.food_id,
                name: record.name,
                calories: record.calories,
                unit: record.unit,
                amount: record.amount,
                mealType: MealType(rawValue: record.meal_type) ?? .breakfast,
                date: DateFormatter.yyyyMMdd.date(from: record.record_date) ?? Date(),
                imageUrl: imageUrl,
                addFoodCategory: record.food_category.flatMap { AddFoodCategory(rawValue: $0) }
            )
        }
    }
    
    func addMealRecord(userId: Int, food: FoodItem) async throws -> (food_id: Int, id: Int) {
        guard let url = URL(string: "\(baseURL)/foods") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var record: [String: Any] = [
            "name": food.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "calories": food.calories,
            "unit": food.unit.trimmingCharacters(in: .whitespacesAndNewlines),
            "date": ISO8601DateFormatter().string(from: food.date),
            "user_id": userId,
            "meal_type": food.mealType?.rawValue ?? "breakfast",
            "amount": food.amount ?? 1.0,
            "food_category": food.addFoodCategory?.rawValue
        ]
        
        // Add image URL (if available)
        if let imageUrl = food.imageUrl, !imageUrl.isEmpty {
            record["image_url"] = imageUrl
            print("Including image URL in food record: \(imageUrl)")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: record)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Server response:", responseString)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let responseData = json["data"] as? [String: Any] {
            
            let foodId = responseData["food_id"] as? Int ?? 0
            let id = responseData["id"] as? Int ?? 0
            
            print("Parsed server response - food_id:", foodId, "id:", id)
            
            if foodId == 0 {
                print("Warning: Server returned zero or missing food_id")
            }
            
            return (food_id: foodId, id: id)
        }
        
        throw URLError(.cannotParseResponse)
    }
    
    // Add delete method
    func deleteMealRecord(id: String) async throws {
        guard let mealUrl = URL(string: "\(baseURL)/meal-records/\(id)") else {
            debugPrint("Delete Error: Invalid URL")
            throw URLError(.badURL)
        }
        
        var mealRequest = URLRequest(url: mealUrl)
        mealRequest.httpMethod = "DELETE"
        
        let (_, mealResponse) = try await URLSession.shared.data(for: mealRequest)
        
        guard let mealHttpResponse = mealResponse as? HTTPURLResponse else {
            debugPrint("Delete Error: Invalid response")
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(mealHttpResponse.statusCode) else {
            debugPrint("Delete Error: Server returned \(mealHttpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        guard let foodUrl = URL(string: "\(baseURL)/food-records/\(id)") else {
            debugPrint("Delete Error: Invalid URL")
            throw URLError(.badURL)
        }
        
        var foodRequest = URLRequest(url: foodUrl)
        foodRequest.httpMethod = "DELETE"
        
        let (_, foodResponse) = try await URLSession.shared.data(for: foodRequest)
        
        guard let foodHttpResponse = foodResponse as? HTTPURLResponse else {
            debugPrint("Delete Error: Invalid response")
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(foodHttpResponse.statusCode) else {
            debugPrint("Delete Error: Server returned \(foodHttpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
    }
    
    // Updating food records
    func updateMealRecord(_ food: FoodItem) async throws {
        guard let serverId = food.serverId else {
            print("Error: No server ID found for food item")
            throw URLError(.badURL)
        }
        
        let endpoint = food.name.hasPrefix("Camera Food") ? "food-records" : "foods"
        guard let url = URL(string: "\(baseURL)/\(endpoint)/\(serverId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        

        var categories = [String: Int]()
        if food.name.hasPrefix("Camera Food") {
            let pattern = "(\\w+): (\\d+)"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let matches = regex.matches(in: food.name, range: NSRange(food.name.startIndex..., in: food.name))
                for match in matches {
                    if let categoryRange = Range(match.range(at: 1), in: food.name),
                       let valueRange = Range(match.range(at: 2), in: food.name) {
                        let category = String(food.name[categoryRange]).lowercased()
                        let value = Int(food.name[valueRange]) ?? 0
                        categories[category] = value
                    }
                }
            }
        }
        
        var record: [String: Any] = [
            "name": food.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "calories": food.calories,
            "unit": food.unit.trimmingCharacters(in: .whitespacesAndNewlines),
            "amount": food.amount ?? 1.0
        ]
        
        if food.name.hasPrefix("Camera Food") {
            record["vegetables"] = categories["vegetables"] ?? 0
            record["fruit"] = categories["fruit"] ?? 0
            record["grains"] = categories["grains"] ?? 0
            record["meat"] = categories["meat"] ?? 0
            record["dairy"] = categories["dairy"] ?? 0
            record["extras"] = categories["extras"] ?? 0
            record["mealType"] = food.mealType?.rawValue ?? "breakfast"
            record["recordDate"] = ISO8601DateFormatter().string(from: food.date)
        }
        
        // Add image URL (if available)
        if let imageUrl = food.imageUrl, !imageUrl.isEmpty {
            record["image_url"] = imageUrl
            print("Including image URL in food update: \(imageUrl)")
        }
        
        print("Sending update request to:", url.absoluteString)
        print("Update data:", record)
        
        request.httpBody = try JSONSerialization.data(withJSONObject: record)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Server response:", responseString)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // Add deleteFoodRecord method
    func deleteFoodRecord(id: String, endpoint: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(endpoint)/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

struct IdResponse: Codable {
    let id: Int
}

struct MealRecord: Codable {
    let userId: Int
    let foodId: Int
    let amount: Double
    let mealType: MealType
    let recordDate: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case foodId = "food_id"
        case amount
        case mealType = "meal_type"
        case recordDate = "record_date"
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let float as Float:
            try container.encode(float)
        default:
            try container.encodeNil()
        }
    }
}

@main
struct foodApp: App {
    @StateObject private var viewModel = FoodViewModel()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(viewModel)
        }
    }
}


class FoodViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var searchTerm = ""
    @Published var foodItems: [FoodItem] = []
    @Published var recentHistory: [FoodItem] = []
    @Published var showImagePicker = false
    @Published var showCamera = false
    @Published var showPopup = false
    @Published var mealCounts: [MealType: Int] = [:]
    @Published var selectedDate = Date()
    

    init() {

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
        

        if UserManager.shared.currentUser != nil {
            Task {
                await loadFoods()
            }
        }
    }
    

    @objc private func userDidLogin() {
        Task {
            await loadFoods()
        }
    }
    

    @objc private func userDidLogout() {
        clearData()
    }
    
    private func clearData() {
        DispatchQueue.main.async {
            self.foodItems = []
            self.recentHistory = []
            self.mealCounts = [:]
            print("User logged out: Cleared all food record data")
        }
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func goToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            DispatchQueue.main.async {
                // First update the date
                self.selectedDate = newDate
                print("Date changed to previous day: \(self.dateString)")
                
                // Then force refresh data
                Task {
                    await self.loadFoods()
                }
            }
        }
    }
    
    func goToNextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            DispatchQueue.main.async {
                // First update the date
                self.selectedDate = newDate
                print("Date changed to next day: \(self.dateString)")
                
                // Then force refresh data
                Task {
                    await self.loadFoods()
                }
            }
        }
    }
    
    // Load all food
    @MainActor
    func loadFoods() async {
        // 1. First check current user status
        if UserManager.shared.currentUser == nil {
            debugPrint("Warning: No logged in user detected, attempting to recover user session")
            
            // 2. Try to restore session from UserDefaults
            if let savedUserId = UserDefaults.standard.object(forKey: "savedUserId") as? Int {
                debugPrint("Found saved user ID: \(savedUserId), attempting to restore session")
                
                // 3. Use synchronous method to wait for user data to load
                let semaphore = DispatchSemaphore(value: 0)
                var userLoaded = false
                
                UserManager.shared.fetchUser(userId: savedUserId) {
                    userLoaded = UserManager.shared.currentUser != nil
                    semaphore.signal()
                }
                
                // Wait for at most 3 seconds
                _ = semaphore.wait(timeout: .now() + 3.0)
                
                if !userLoaded {
                    debugPrint("Error: Failed to restore user session")
                    DispatchQueue.main.async {
                        self.foodItems = []
                        self.mealCounts = [:]
                    }
                    return
                }
            } else {
                debugPrint("Error: No logged in user and no saved user ID found")
                DispatchQueue.main.async {
                    self.foodItems = []
                    self.mealCounts = [:]
                }
                return
            }
        }
        
        guard let user = UserManager.shared.currentUser else {
            debugPrint("Error: No logged in user, cannot load food records")
            DispatchQueue.main.async {
                self.foodItems = []
                self.mealCounts = [:]
            }
            return
        }
        
        // 4. If we reach here, user status should be restored or confirmed
        let userId = user.user_id
        debugPrint("Loading food records for user ID: \(userId)")
        
        do {
            let newFoodItems = try await NetworkService.shared.getMealRecords(userId: userId, date: selectedDate)
            
            DispatchQueue.main.async {
                self.foodItems = newFoodItems
                self.updateMealCounts()
            }
        } catch {
            debugPrint("Error loading foods:", error)
            DispatchQueue.main.async {
                self.foodItems = []
                self.mealCounts = [:]
            }
        }
    }
    
    // Modify delete method
    @MainActor
    func deleteFood(_ food: FoodItem) async {
        do {
            if let serverId = food.serverId {
        
                let endpoint = food.name.hasPrefix("Camera Food") ? "food-records" : "foods"
                try await NetworkService.shared.deleteFoodRecord(id: String(serverId), endpoint: endpoint)
                
                if let index = foodItems.firstIndex(where: { $0.id == food.id }) {
                    foodItems.remove(at: index)
                }
                
                updateMealCounts()
            } else {
                debugPrint("Delete Error: Missing serverId")
            }
        } catch {
            debugPrint("Delete Error:", error.localizedDescription)
        }
    }
    
    // You also don't need to reload all your data after adding food
    @MainActor
    func addFood(_ food: FoodItem) async {
        do {
            guard let userId = UserManager.shared.currentUser?.user_id else {
                debugPrint("Error: Cannot add food - no logged in user")
                return
            }
            
            let localFood = FoodItem(
                id: food.id,
                serverId: food.serverId,
                recordId: food.recordId,
                name: food.name,
                calories: food.calories,
                unit: food.unit,
                amount: food.amount,
                mealType: food.mealType,
                date: food.date,
                imageUrl: food.imageUrl,
                addFoodCategory: food.addFoodCategory
            )
            
            foodItems.append(localFood)
            updateMealCounts()
            
            let response = try await NetworkService.shared.addMealRecord(userId: userId, food: food)

            if let index = foodItems.firstIndex(where: { $0.id == localFood.id }) {
                foodItems[index].serverId = response.food_id
            }
        } catch {
            debugPrint("Error adding food:", error)
        }
    }
    
  
    @MainActor
    func updateFood(_ food: FoodItem) async {
        do {
            try await NetworkService.shared.updateMealRecord(food)
            
            if let index = foodItems.firstIndex(where: { $0.id == food.id }) {
                foodItems[index] = food
            }
            
            updateMealCounts()
        } catch {
            debugPrint("Error updating food:", error)
        }
    }
    
  
    private func updateMealCounts() {
        var counts: [MealType: Int] = [:]
        let todayItems = foodItems.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        
        for type in MealType.allCases {
            counts[type] = todayItems.filter { $0.mealType == type }.count
        }
        
        self.mealCounts = counts
    }
    

    var dateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: selectedDate)
        }
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
