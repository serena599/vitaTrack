//
//  GoalSetting.swift
//  NutritionGoal
//
//  Created by CHIHCHEN on 2025/3/3.
//

import SwiftUI
import Foundation

struct GoalSettingView: View {
    @State private var vegetables: String
    @State private var fruits: String
    @State private var grains: String
    @State private var meat: String
    @State private var dairy: String
    @State private var extras: String
    @State private var showAlert = false

    init(vegetables: String, fruits: String, grains: String, meat: String, dairy: String, extras: String) {
        _vegetables = State(initialValue: vegetables)
        _fruits = State(initialValue: fruits)
        _grains = State(initialValue: grains)
        _meat = State(initialValue: meat)
        _dairy = State(initialValue: dairy)
        _extras = State(initialValue: extras)
    }

    var body: some View {
        VStack {
            // Title
            Text("Goal Setting")
                .font(.title)
                .bold()
                .padding()

            // Form Content
            Form {
                Group {
                    GoalSettingRow(iconName: "leaf", category: "Vegetables", value: $vegetables, minValue: "Serve(s)")
                    GoalSettingRow(iconName: "applelogo", category: "Fruit", value: $fruits, minValue: "Serve(s)")
                    GoalSettingRow(iconName: "bag", category: "Grains", value: $grains, minValue: "Serve(s)")
                    GoalSettingRow(iconName: "fish", category: "Meat", value: $meat, minValue: "Serve(s)")
                    GoalSettingRow(iconName: "drop", category: "Dairy", value: $dairy, minValue: "Serve(s)")
                    GoalSettingRow(iconName: "flame", category: "Extras", value: $extras, minValue: "Serve(s)")
                }
            }

            // Note
            Text("* Recommended number of serves based on Australian Dietary Guidelines")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding()

            // Buttons
            HStack(spacing: 20) {
                Button(action: {
                    // Cancel action
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customPink)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    // Confirm action
                    //let userId = 1  // your user ID
                    let userId = UserManager.shared.currentUser?.user_id                      
                    let url = URL(string: "\(SERVER_URL)/update_goal")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    let goalData: [String: Any] = [
                        "userId": userId,
                        "vegetables": vegetables,
                        "fruits": fruits,
                        "grains": grains,
                        "meat": meat,
                        "dairy": dairy,
                        "extras": extras
                    ]

                    request.httpBody = try? JSONSerialization.data(withJSONObject: goalData)

                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("❌ Failed to save data: \(error.localizedDescription)")
                        } else {
                            print("✅ Data saved successfully!")
                            showAlert = true
                        }
                    }.resume()
                }) {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.loginGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Success"), message: Text("Goal Saved Successfully"), dismissButton: .default(Text("OK")))
        }
    }
}

struct GoalSettingRow: View {
    var iconName: String
    var category: String
    @Binding var value: String
    var minValue: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.green)
                .frame(width: 30, height: 30)

            Text(category)

            Spacer()

            TextField("", text: $value)
                .frame(width: 60)
                //.textFieldStyle(RoundedBorderTextFieldStyle())
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(.numberPad)

            Text(minValue)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}

struct GoalSettingView_Previews: PreviewProvider {
    static var previews: some View {
        GoalSettingView(vegetables: "5", fruits: "2", grains: "6", meat: "2.5", dairy: "2.5", extras: "0")
    }
}


//
//  GoalSetting.swift
//  NutritionGoal
//
//  Created by CHIHCHEN on 2025/3/3.
//
