import SwiftUI

struct HomepageView: View {
    //@StateObject var viewModel = HomepageViewModel()
    @AppStorage("userId") private var userId: Int = 0
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject var viewModel: HomepageViewModel
    
    var body: some View {
        VStack(spacing: 0) {
           
            if !userManager.isLoggedIn {
                Text("Please log in to see your progress")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            VStack(spacing: 30) {
                Button(action: {
                    viewModel.showDatePicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.black)
                        Text(viewModel.dateFormatter.string(from: viewModel.selectedDate))
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
                .sheet(isPresented: $viewModel.showDatePicker) {
                    VStack {
                        DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                        
                        Button("Done") {
                        
                            let effectiveUserId = userManager.currentUser?.user_id ?? userId
                            viewModel.fetchNutritionProgress(for: viewModel.selectedDate, userId: effectiveUserId)
                            viewModel.showDatePicker = false
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.customGreen)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    }
                    .presentationDetents([.medium])
                }
                .padding(.top, 20)
                
                // Progress Ring
                ProgressRingView(progress: viewModel.totalProgress)
                    .padding(.vertical, 20)
                
                // Display network error if any
                if let error = viewModel.networkError {
                    Text("Error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                // Motivational Message
                Text(viewModel.motivationalMessage)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                
                // Action Buttons
                VStack(spacing: 25) {
                    HomepageActionButton(
                        title: "Set",
                        subtitle: "Your Goal",
                        buttonText: "Set Now",
                        backgroundColor: .customGreen,
                        destination: AnyView(NutritionGoalView2())
                    )
                    
                    HomepageActionButton(
                        title: "Track",
                        subtitle: "Your Progress",
                        buttonText: "Track Now",
                        backgroundColor: .customPink,
                        destination: AnyView(GoalTrackingView())
                    )
                }
                
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("")
        .background(Color.white)
        .onAppear {
            // Use user ID from userManager, or from AppStorage if not available
            let effectiveUserId = userManager.currentUser?.user_id ?? userId
            
            if userManager.isLoggedIn {
                viewModel.loadGoalSettings(userId: effectiveUserId)
                viewModel.fetchNutritionProgress(for: viewModel.selectedDate, userId: effectiveUserId)
            } else {
                // Can add logic to navigate to login page here
            }
        }
        // Monitor login status changes
        .onChange(of: userManager.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                let effectiveUserId = userManager.currentUser?.user_id ?? userId
                // Update AppStorage userId with the current user's ID
                userId = userManager.currentUser?.user_id ?? 0
                viewModel.loadGoalSettings(userId: effectiveUserId)
                viewModel.fetchNutritionProgress(for: viewModel.selectedDate, userId: effectiveUserId)
            }
        }
    }
}

#Preview {
    HomepageView()
        .environmentObject(UserManager()) // Add environment object
        .environmentObject(HomepageViewModel())
}
