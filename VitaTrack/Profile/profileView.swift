import SwiftUI
import PhotosUI

// Profile view
struct ProfileView: View {
    @EnvironmentObject var homeViewModel: HomepageViewModel
    @EnvironmentObject var userManager: UserManager
    @State private var showEditProfile = false
    @State private var showSetting = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showPhotoOptions = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showLoginView = false

    var body: some View {
        VStack(spacing: 0) {
            titleView
            
            if userManager.isLoading {
                loadingView
            } else {
                profileSection
                menuSection
            }
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
    
    
    private var titleView: some View {
        HStack {
            Spacer()
            Text("VitaTrack")
                .font(.system(size: 22, weight: .bold))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
        .padding(.top, 50)
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading...")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.8))
    }
    
    private var profileSection: some View {
        VStack(spacing: 10) {
            profileImageView
            profileInfoView
        }
        .padding(.vertical, 28)
    }
    
    private var profileImageView: some View {
        ZStack(alignment: .bottomTrailing) {
            profileImage
            
            if userManager.isLoggedIn {
                cameraButton
            }
        }
        .onTapGesture {
            if userManager.isLoggedIn {
                showPhotoOptions = true
            } else {
                showLoginView = true
            }
        }
        .confirmationDialog("Choose Photo", isPresented: $showPhotoOptions) {
            Button("Take Photo") {
                showCamera = true
            }
            
            Button("Choose from Library") {
                showImagePicker = true
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $photoPickerItem,
            matching: .images,
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()
        )
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                if let image = image {
                    userManager.uploadAvatar(image: image)
                }
            }
        }
        .onChange(of: photoPickerItem) { oldValue, newValue in
            Task {
                do {
                    if let newItem = newValue {
                        if let data = try await newItem.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                let compressedImage = compressImage(uiImage, maxSizeKB: 500)
                                userManager.uploadAvatar(image: compressedImage)
                            }
                        }
                    }
                } catch {
                    // Error handling could be improved here if needed
                }
            }
        }
    }
    
    // Image compression function
    private func compressImage(_ image: UIImage, maxSizeKB: Int) -> UIImage {
        var compression: CGFloat = 1.0
        let maxBytes = maxSizeKB * 1024
        
        guard var imageData = image.jpegData(compressionQuality: compression) else { return image }
        
        while imageData.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            if let newData = image.jpegData(compressionQuality: compression) {
                imageData = newData
            }
        }
        
        return UIImage(data: imageData) ?? image
    }
    
    private var profileImage: some View {
        Group {
            if userManager.isLoggedIn, let image = userManager.currentUser?.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 50))
                    )
            }
        }
    }
    
    private var cameraButton: some View {
        Image(systemName: "camera.fill")
            .foregroundColor(.white)
            .padding(6)
            .background(Color("AccentColor"))
            .clipShape(Circle())
            .offset(x: 5, y: 5)
    }
    
    private var profileInfoView: some View {
        Group {
            if userManager.isLoggedIn {
                loggedInUserInfo
            } else {
                guestUserInfo
            }
        }
    }
    
    private var loggedInUserInfo: some View {
        VStack(spacing: 4) {
            Text(userManager.currentUser?.fullName ?? "Guest")
                .font(.system(size: 24, weight: .medium))
            
            // Username (@username) display line has been removed
            
            Text("Joined \(userManager.currentUser?.joinedYear ?? "")")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
    }
    
    private var guestUserInfo: some View {
        VStack {
            Text("Guest")
                .font(.system(size: 24, weight: .medium))
            
            Text("Not logged in")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            Button(action: {
                showLoginView = true
            }) {
                Text("Login")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.foodPrimary)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showLoginView) {
                LoginView()
                    .environmentObject(userManager)
                    .onReceive(userManager.$isLoggedIn) { isLoggedIn in
                        if isLoggedIn {
                            showLoginView = false
                        }
                    }
            }
        }
    }
    
    private var menuSection: some View {
        Group {
            if userManager.isLoggedIn {
                loggedInMenuItems
            } else {
                guestMessage
            }
        }
    }
    
    private var loggedInMenuItems: some View {
        VStack(spacing: 10) {
            Button(action: {
                showEditProfile = true
            }) {
                MenuRow(title: "Profile", icon: "person", fontSize: 18)
            }
            .sheet(isPresented: $showEditProfile) {
                if let currentUser = userManager.currentUser {
                    EditProfileView()
                        .environmentObject(userManager)
                }
            }
            
            NavigationLink(destination: NutritionGoalView2()) {
                MenuRow(title: "Goal Setting", icon: "target", fontSize: 18)
            }
            
            NavigationLink(destination: GoalTrackingView()) {
                MenuRow(title: "Goal Tracking", icon: "chart.bar.xaxis", fontSize: 18)
            }
            
            Button(action: {
                showSetting = true
            }) {
                MenuRow(title: "Setting", icon: "gear", fontSize: 18)
            }
            .sheet(isPresented: $showSetting) {
                Setting()
                    .environmentObject(userManager)
                    .environmentObject(homeViewModel)
            }
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 0)
    }
    
    private var guestMessage: some View {
        VStack {
            Text("Login to access your profile and settings")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
                .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView().environmentObject(UserManager()).environmentObject(HomepageViewModel())
    }
}
