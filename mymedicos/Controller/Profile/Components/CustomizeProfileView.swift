import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

struct CustomizeProfileView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var whatsappNumber: String = ""
    @State private var dob: Date = Date() // Using Date type for DatePicker compatibility
    @State private var gender: String = "Not Specified"
    let genderOptions = ["Male", "Female", "Non-Binary", "Not Specified"]
    @State private var isEditing: Bool = false
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var imageChanged = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showingActionSheet = true
                            }) {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .actionSheet(isPresented: $showingActionSheet) {
                                ActionSheet(title: Text("Select an option"), buttons: [
                                    .default(Text("Take a Photo")) {
                                        self.sourceType = .camera
                                        self.showingImagePicker = true
                                    },
                                    .default(Text("Select an Image")) {
                                        self.sourceType = .photoLibrary
                                        self.showingImagePicker = true
                                    },
                                    .cancel()
                                ])
                            }
                            .sheet(isPresented: $showingImagePicker) {
                                ImagePicker(image: $profileImage, imageChanged: $imageChanged, sourceType: self.sourceType)
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    Section(header: Text("PERSONAL DETAILS")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(Color.black.opacity(0.8))) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("NAME")
                                    .font(.custom("Inter-SemiBold", size: 12))
                                    .foregroundColor(Color.gray)
                                Spacer()
                            }
                            Text(name)
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(isEditing ? Color.black : Color.gray)
                        }
                        .padding(.vertical, 5)

                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("EMAIL ADDRESS")
                                    .font(.custom("Inter-SemiBold", size: 12))
                                    .foregroundColor(Color.gray)
                                Spacer()
                            }
                            Text(email)
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(isEditing ? Color.black : Color.gray)
                        }
                        .padding(.vertical, 5)

                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("MOBILE NUMBER")
                                    .font(.custom("Inter-SemiBold", size: 12))
                                    .foregroundColor(Color.gray)
                                Spacer()
                            }
                            Text(phoneNumber)
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(isEditing ? Color.black : Color.gray)
                        }
                        .padding(.vertical, 5)

                        Button("Verify KYC") {
                            // KYC Verification Action
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                    
                    Section(header: Text("EDUCATION DETAILS")
                                 .font(.custom("Inter-SemiBold", size: 16))
                                 .foregroundColor(Color.black.opacity(0.8))) {
                         Button(action: {
                             // Add Education Action
                         }) {
                             Text("+ Add Education")
                                 .frame(maxWidth: .infinity)
                                 .padding()
                                 .background(Color.gray.opacity(0.1))
                                 .foregroundColor(.black)
                                 .cornerRadius(5)
                                 .overlay(
                                     RoundedRectangle(cornerRadius: 5)
                                         .stroke(Color.gray, lineWidth: 0.4)
                                 )
                         }
                         .padding(.vertical, 1)
                     }
                     .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

                    Section(header: Text("OTHER DETAILS")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(Color.black.opacity(0.8))) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("DATE OF BIRTH")
                                    .font(.custom("Inter-SemiBold", size: 12))
                                    .foregroundColor(Color.gray)
                                Spacer()
                                if isEditing {
                                    DatePicker(
                                        "Select Date",
                                        selection: $dob,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .foregroundColor(.blue)
                                }
                            }
                            Text(dob, style: .date) // Displaying the date
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(isEditing ? Color.black : Color.gray)
                                .padding(.vertical, 5)

                            HStack {
                                Text("GENDER")
                                    .font(.custom("Inter-SemiBold", size: 12))
                                    .foregroundColor(Color.gray)
                                Spacer()
                                if isEditing {
                                    Picker("Select Gender", selection: $gender) {
                                        ForEach(genderOptions, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                            }
                            Text(gender)
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(isEditing ? Color.black : Color.gray)
                        }
                        .padding(.vertical, 5)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
                }

                if imageChanged {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                saveProfileImage()
                            }) {
                                Text("Save")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                isEditing.toggle()
                if !isEditing && imageChanged {
                    saveProfileImage()
                }
            }) {
                Image(systemName: isEditing ? "checkmark" : "pencil")
                    .foregroundColor(.blue)
            })
        }
        .onAppear {
            fetchData()
            fetchProfileImage()
        }
    }

    func fetchData() {
        guard let user = Auth.auth().currentUser, let currentPhoneNumber = user.phoneNumber else {
            print("User not authenticated or phone number not available")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").whereField("Phone Number", isEqualTo: currentPhoneNumber).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }

            guard let document = snapshot?.documents.first else {
                print("No matching user found")
                return
            }

            let data = document.data()
            self.name = data["Name"] as? String ?? "Unknown"
            self.email = data["Email ID"] as? String ?? "Unknown"
            self.phoneNumber = data["Phone Number"] as? String ?? "Unknown"
            self.whatsappNumber = data["Phone Number"] as? String ?? "Unknown"
            self.dob = (data["DOB"] as? Timestamp)?.dateValue() ?? Date()
            self.gender = data["Gender"] as? String ?? "Not Specified"
        }
    }

    func saveProfileImage() {
        guard let image = profileImage,
              let imageData = image.jpegData(compressionQuality: 0.75),
              let user = Auth.auth().currentUser,
              let phoneNumber = user.phoneNumber else {
            return
        }

        let storageRef = Storage.storage().reference(withPath: "users/\(phoneNumber)/profile_image.jpg")
        
        // Create metadata for the image
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" // Set MIME type to image/jpeg

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
            } else {
                print("Profile image successfully uploaded with MIME type: \(metadata?.contentType ?? "unknown")")
                imageChanged = false // Reset the imageChanged flag after successful upload
            }
        }
    }


    func fetchProfileImage() {
        guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber else {
            return
        }

        let storageRef = Storage.storage().reference(withPath: "users/\(phoneNumber)/profile_image.jpg")
        let localURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("profile_image.jpg")

        storageRef.write(toFile: localURL) { url, error in
            if let error = error {
                print("Error downloading image: \(error)")
            } else if let url = url, let image = UIImage(contentsOfFile: url.path) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }

}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var imageChanged: Bool
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.imageChanged = true
            }

            picker.dismiss(animated: true)
        }
    }
}

struct CustomizeProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeProfileView()
    }
}
