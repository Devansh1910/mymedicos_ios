import SwiftUI

struct Aboutus: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                Text("mymedicos")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 0)
                
                Divider()
                
                // Description
                Text("""
                At Broverg Corporation, our mission is to provide cutting-edge IT solutions and services that enhance productivity, efficiency, and growth for our clients. We strive to deliver unparalleled customer satisfaction by leveraging our expertise, creativity, and passion for technology. Through collaboration, innovation, and a commitment to excellence, we aim to build long-lasting partnerships and enable our clients to navigate the ever-evolving digital landscape with confidence.
                """)
                .font(.body)
                
                // Leadership Section
                Text("Our Leadership")
                    .font(.headline)
                    .padding(.top, 10)
                
                Divider()
                
                // Leadership Profiles
                VStack(spacing: 10) {
                    LeaderProfile(name: "Deepak Nellikoppa", title: "Co-Founder, and CEO", imageName: "deepak")
                    LeaderProfile(name: "Devansh Saxena", title: "CTO (Chief Technology Officer)", imageName: "devansh")
                    LeaderProfile(name: "Madhumati Hemakar", title: "CMO (Chief Marketing Officer)", imageName: "madhu")
                    LeaderProfile(name: "Vaishnavi Sanikop", title: "CFO (Chief Financial Officer)", imageName: "vaishnavi")
                }
                
                // Contact Details Section
                Text("Contact Details")
                    .font(.headline)
                    .padding(.top, 10)
                
                Divider()
                
                // Call to Action
                Text("Join us in our journey toward success and help bring our mission to life. Your involvement will make PrepLadder a fantastic place to live, work, and thrive. Become a part of our team today!")
                    .font(.body)
                
                // Email Input Field (Mock)
                TextField("Enter your email Id", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top, 10)
            }
            .padding()
            .background(Color.white) // Set the background color to white
        }
        .background(Color.white) // Set the background color to white
        .preferredColorScheme(.light) // Force light mode
        .navigationBarTitle("About Us", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct LeaderProfile: View {
    var name: String
    var title: String
    var imageName: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                .shadow(radius: 3)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.body)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        Aboutus()
    }
}
