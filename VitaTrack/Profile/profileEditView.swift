import SwiftUI
import PhotosUI

// Edit profile view
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var gender: String = ""
    @State private var dob: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var isShowingImagePicker = false
    @State private var showCamera = false
    @State private var showPhotoOptions = false
    @State private var profileImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        VStack {
            Text("Edit Profile")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 20)

            ScrollView {
                VStack(spacing: 20) {
                    // Profile image selector
                    VStack {
                        Button(action: {
                            showPhotoOptions = true
                        }) {
                            ZStack(alignment: .bottomTrailing) {
                                if let image = profileImage {
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

                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.foodPrimary)
                                    .clipShape(Circle())
                                    .offset(x: 5, y: 5)
                            }
                        }
                        .confirmationDialog("Choose Photo", isPresented: $showPhotoOptions) {
                            Button("Take Photo") {
                                showCamera = true
                            }

                            Button("Choose from Library") {
                                isShowingImagePicker = true
                            }

                            Button("Cancel", role: .cancel) {}
                        }
                        .photosPicker(isPresented: $isShowingImagePicker, selection: $photoPickerItem, matching: .images)
                        .fullScreenCover(isPresented: $showCamera) {
                            CameraView { image in
                                if let image = image {
                                    profileImage = image
                                }
                            }
                        }
                        .onChange(of: photoPickerItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = uiImage
                                }
                            }
                        }

                        Text("Tap to change profile picture")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)

                    // Form fields
                    SimpleFormField(title: "First Name", placeholder: "Enter your first name", text: $firstName)
                    SimpleFormField(title: "Last Name", placeholder: "Enter your last name", text: $lastName)

                    // Gender selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)

                        Menu {
                            Button("Male") { gender = "Male" }
                            Button("Female") { gender = "Female" }
                            Button("Other") { gender = "Other" }
                        } label: {
                            HStack {
                                Text(gender)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black)
                                    .font(.system(size: 14))
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    // Date of Birth picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date of Birth")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)

                        VStack {
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                HStack {
                                    Text(formatDate(dob))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }

                            if showDatePicker {
                                DatePicker("", selection: $dob, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding()
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(8)
                                    .labelsHidden()
                                    .onChange(of: dob) { _ in
                                        showDatePicker = false
                                    }
                            }
                        }
                    }

                    SimpleFormField(title: "Phone", placeholder: "Enter your phone number", text: $phone, keyboardType: .phonePad)
                    SimpleFormField(title: "Email", placeholder: "Enter your email", text: $email, keyboardType: .emailAddress)

                    // Save button
                    Button(action: {
                        saveChanges()
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.foodPrimary)
                            .cornerRadius(8)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .onAppear {
            // Initialize form fields
            if let user = userManager.currentUser {
                firstName = user.firstName
                lastName = user.lastName
                gender = user.gender
                dob = user.dob
                phone = user.phone
                email = user.email
                profileImage = user.image
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func saveChanges() {
        var updatedUser = userManager.currentUser!
        updatedUser.firstName = firstName
        updatedUser.lastName = lastName
        updatedUser.gender = gender
        updatedUser.dob = dob
        updatedUser.phone = phone
        updatedUser.email = email
        if let newImage = profileImage {
            updatedUser.image = newImage
        }

        userManager.updateUserInfo(newUser: updatedUser)
        presentationMode.wrappedValue.dismiss()
    }
}
