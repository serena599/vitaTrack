import SwiftUI

// Reset password view
struct NotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager
    
    // Receive HomepageViewModel instance from Settings
    @EnvironmentObject var homeViewModel: HomepageViewModel
    
    @State private var isNotificationEnabled = UserDefaults.standard.bool(forKey: "isNotificationEnabled") // Control switch, read stored status
    @State private var selectedTime: Date = UserDefaults.standard.object(forKey: "selectedTime") as? Date ?? Date() // Read stored time
    @State private var showAlert = false               // Provide feedback when notification is set
    
    // Reference data from user's Goal Setting
    //@State private var currentCalories = 1800  // Today's calorie intake (example)
    //@State private var targetCalories = 2000   // Target calorie intake (example)

    var body: some View {
        NavigationView {
            Form {
                
                Section(" ") {
                    // Toggle to enable/disable notification function
                    Toggle("Daily Notification", isOn: $isNotificationEnabled)
                        .padding()
                        .onChange(of: isNotificationEnabled) {
                            UserDefaults.standard.set(isNotificationEnabled, forKey: "isNotificationEnabled") // Store toggle state
                            if isNotificationEnabled {
                                requestNotificationPermission()
                            } else {
                                removeNotification()
                            }
                        }
                }
                
                // When toggle is on, show time picker and button
                if isNotificationEnabled {
                    Section(" ") {
                        // Select message sending time
                        DatePicker("Seclect time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .onChange(of: selectedTime) {
                                UserDefaults.standard.set(selectedTime, forKey: "selectedTime") // Store selected time
                        }
                    }
                    
                    Section(" ") {
                        // Button to set time and schedule notification
                        Button(action: scheduleNotification) {
                            Text("Set Notification")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.foodPrimary)
                                .cornerRadius(8)
                        }
                        .padding()
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Notification set"), message: Text("Set daily notification at \(formattedTime()) "), dismissButton: .default(Text("OK")))
                        }
                    }
                }
            }
            .navigationTitle("Notification Setup")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            isNotificationEnabled = UserDefaults.standard.bool(forKey: "isNotificationEnabled") // Ensure status is restored each time page is entered
            selectedTime = UserDefaults.standard.object(forKey: "selectedTime") as? Date ?? Date() // Restore stored time
        }
    }
    
    // Send local notification
    func scheduleNotification() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)

        let content = UNMutableNotificationContent()
        content.title = "Daily Notification"
        content.body = generateMessageContent()  // Use dynamically generated message content
        content.sound = .default
        content.userInfo = ["targetPage": "GoalTrackingView"]

        var triggerDate = DateComponents()
        triggerDate.hour = components.hour
        triggerDate.minute = components.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Add notification failed: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    showAlert = true
                }
            }
        }
    }
    
    // Generate message based on GoalSetting targets and user's current completion status. Currently test data
    func generateMessageContent() -> String {
        // Get total progress
        let progress = homeViewModel.totalProgress
        let goalMessage = homeViewModel.motivationalMessage
        
        print("progress is: \(progress)")
        print("goalMessage is: \(goalMessage)")

        // Example logic: Determine message based on current progress
        if progress < 0.3 {
            return "You haven't started much today! \(goalMessage)"
        } else if progress < 0.7 {
            return "You've completed more than half of your dietary goals, keep going! \(goalMessage)"
        } else if progress < 1.0 {
            return "Almost completed today's dietary goal, one final push! \(goalMessage)"
        } else {
            return "🎉 Congratulations on completing today's dietary goal! \(goalMessage)"
        }
    }

    // Request notification permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Request authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Remove set notifications
    func removeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
            print("Daily Notification cancelled.")
    }

    // Format time
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
}

// Preview for reset password view
struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
            .environmentObject(UserManager())
            .environmentObject(HomepageViewModel())
    }
}
