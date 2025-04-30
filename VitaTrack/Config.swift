import Foundation

struct Config {
    // Automatically switch based on environment
    static let baseURL: String = {
        #if targetEnvironment(simulator)
        return "http://localhost:4000"
        #else
        return "http://192.168.20.5:4000"
        #endif
    }()
}

// Global constant accessible from any file
let SERVER_URL = Config.baseURL 
