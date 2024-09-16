import SwiftUI
import Firebase

struct SettingsUIView: View {
    @State private var notificationsEnabled = false
    @State private var vibrationsEnabled = false
    @State private var showVibrationAlert = false
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("ACCOUNT").font(.callout)) {
                    NavigationLink(destination: ProfileScreen()) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .imageScale(.medium)
                            Text("Profile")
                                .font(.subheadline)
                        }
                    }
                }

                Section(header: Text("APP SETTINGS").font(.callout)) {
                    Toggle("Notification", isOn: $notificationsEnabled)
                    Toggle("Vibration", isOn: $vibrationsEnabled)
                        .onChange(of: vibrationsEnabled) { newValue in
                            if newValue {
                                showVibrationAlert = true
                            }
                        }
                }

                Section(header: Text("APPS").font(.callout)) {
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/in/app/microsoft-word/id462054704?mt=12") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                                .imageScale(.medium)
                                .foregroundColor(.red)
                            Text("Rate us")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }

                Section(header: Text("DELETE ACCOUNT").font(.callout)) {
                    NavigationLink(destination: Text("Delete Account View")) {
                        HStack {
                            Image(systemName: "person.fill.badge.minus")
                                .imageScale(.medium)
                            Text("Delete Account")
                                .font(.subheadline)
                        }
                    }
                }

                Section(header: Text("LOGOUT ACCOUNT").font(.callout)) {
                    Button(action: {
                        self.showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .imageScale(.medium)
                                .foregroundColor(.red)
                            Text("Logout")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                    .alert(isPresented: $showingLogoutAlert) {
                        Alert(
                            title: Text("Confirm Logout"),
                            message: Text("Are you sure you want to logout?"),
                            primaryButton: .destructive(Text("Logout")) {
                                logout()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .background(Color.white)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color.white) // Sets the NavigationView's background color
        .environment(\.colorScheme, .light) // Enforce light mode for this view
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            // Handle navigation to the login screen or reset the user session state
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // Optionally show an error message to the user
        }
    }
}

struct ProfileScreen: View {
    var body: some View {
        CustomizeProfileView()
    }
}

struct SettingsUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsUIView()
    }
}
