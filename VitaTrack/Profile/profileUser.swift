import SwiftUI

struct User {
    var firstName: String
    var lastName: String
    var username: String
    var joinedYear: String
    var image: UIImage?
    var gender: String
    var dob: Date
    var phone: String
    var email: String
    var user_id: Int
    var avatarPath: String?
    var password: String

    // Calculate full name
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}
