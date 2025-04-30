import SwiftUI

///  Main content view
struct ContentView: View {
    /// Global view model
    @EnvironmentObject private var viewModel: FoodViewModel
    /// The index of the currently selected TAB
    @State private var selectedTab = 1
    /// Whether to display full screen camera
    @State private var showFullScreenCamera = false
    
    // Receive HomepageViewModel instance from AppView
    @EnvironmentObject var homeViewModel: HomepageViewModel
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    // Main content area
                    TabView(selection: $selectedTab) {
                        HomepageView()
                            .tag(1)
                            //.environmentObject(homeViewModel)
                        SearchView(show_favorite_recipes: false)
                            .tag(2)
                        Color.clear
                            .tag(3)
                        FoodView()
                            .tag(4)
                        ProfileView()
                            .tag(5)
                            //.environmentObject(homeViewModel)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Bottom navigation bar, hidden in full screen mode
                    if !showFullScreenCamera {
                        HStack(spacing: 0) {
                            GeometryReader { geometry in
                                HStack(spacing: 0) {
                                    TabBarButtonView(
                                        icon: "house.fill",
                                        isSelected: selectedTab == 1
                                    )
                                    .onTapGesture {
                                        selectedTab = 1
                                        showFullScreenCamera = false
                                    }
                                    .offset(y: -8)
                                    
                                    TabBarButtonView(
                                        icon: "magnifyingglass",
                                        isSelected: selectedTab == 2
                                    )
                                    .onTapGesture {
                                        selectedTab = 2
                                        showFullScreenCamera = false
                                    }
                                    .offset(y: -8)
                                    
                                    Button(action: {
                                        showFullScreenCamera = true
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.foodPrimary)
                                                .frame(width: 55, height: 55)
                                            
                                            Image(systemName: "camera")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .offset(y: -10)
                                    .frame(width: geometry.size.width / 5)
                                    
                                    TabBarButtonView(
                                        icon: "book",
                                        isSelected: selectedTab == 4,
                                        strokeStyle: true
                                    )
                                    .onTapGesture {
                                        selectedTab = 4
                                        showFullScreenCamera = false
                                    }
                                    .offset(y: -8)
                                    
                                    TabBarButtonView(
                                        icon: "person.fill",
                                        isSelected: selectedTab == 5
                                    )
                                    .onTapGesture {
                                        selectedTab = 5
                                        showFullScreenCamera = false
                                    }
                                    .offset(y: -8)
                                }
                                .frame(maxHeight: .infinity)
                                .frame(width: geometry.size.width)
                            }
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                        .background(Color.white)
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
           
            if showFullScreenCamera {
                FoodScanView()
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .overlay(
                        VStack {
                            HStack {
                                Button(action: {
                                    showFullScreenCamera = false
                                    selectedTab = 1
                                }) {
                                    Image(systemName: "arrow.left")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                                .padding()
                                Spacer()
                            }
                            Spacer()
                        }
                    )
            }
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut, value: showFullScreenCamera)
    }
}

/// Customize the bottom navigation buttons
struct TabBarButtonView: View {
    let icon: String
    let isSelected: Bool
    var strokeStyle: Bool = false
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 20))
            .foregroundColor(isSelected ? .foodPrimary : .gray)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager.shared)
        .environmentObject(FoodViewModel())
}
