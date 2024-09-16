//import SwiftUI
//
//struct PromotionScreen: View {
//    var body: some View {
//        VStack {
//            // Top Image
//            Image("Premium") // Replace with your image name
//                .resizable()
//                .scaledToFit() // Ensures the image maintains its aspect ratio and fits the screen width
//                .frame(maxWidth: .infinity) // Make the image fill the width of the screen
//
//            Text("Your First Look at the Future")
//                .font(.title)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .fontWeight(.bold)
//                .padding()
//
//            Text("Love More with Every Step: Clear the Future Today, Embark on Tomorrow’s Possibilities, and Be Part of Innovation That Lasts")
//                .fontWeight(.semibold)
//                .font(.headline)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding()
//
//            // Feature list
//            VStack(alignment: .leading, spacing: 10) {
//                FeatureView(icon: "book.fill", text: "Retain more with Subject & Topic-wise Treasures")
//                FeatureView(icon: "bookmark.fill", text: "Directly bookmark topics from the index")
//                FeatureView(icon: "play.fill", text: "Access Treasures conveniently from 'Resume where we left' section")
//            }
//            .padding(.horizontal)
//
//            Spacer()
//
//            // Bottom Button
//            Button(action: {}) {
//                Text("Get started")
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.yellow)
//                    .cornerRadius(10)
//            }
//            .padding()
//
//        }
//        .background(Color.white) // Set background color to white
//        .foregroundColor(.black) // Set default text color to black
//        .edgesIgnoringSafeArea(.all) // Ensure the background covers the entire screen
//    }
//}
//
//// Helper view to display each feature with an icon and text
//struct FeatureView: View {
//    let icon: String
//    let text: String
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 10) {
//            Image(systemName: icon)
//                .foregroundColor(.yellow)
//                .frame(width: 30, height: 30)
//            
//            Text(text)
//                .font(.body)
//                .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading) // Align the whole HStack to the left
//    }
//}
//
//// Preview
//struct PromotionScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        PromotionScreen()
//    }
//}
