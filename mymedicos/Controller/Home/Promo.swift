import SwiftUI
import Lottie

struct Promo: View {
    var body: some View {
        VStack {
            // Animation View
            LottieView(name: "foralpha")
                .frame(height: 100) // Adjust height for animation
                .frame(width: 100)
                .padding(.top, 0)
            
            // Text and icons that appear one by one
            VStack(alignment: .leading, spacing: 0) {
                
                // Title Section
                Text("Unleash your potential")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.top, 200)
                
                Text("Alpha Edition Awaits")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                
                Text("Empowering your FMGE journey with tailored resources, expert guidance, and innovative learning tools!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Bullet points with icons
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.red)
                        VStack(alignment: .leading) {
                            Text("Practice sets:")
                                .font(.subheadline)
                                .bold()
                            Text("tailored questions for FMGE success.")
                                .foregroundColor(.gray)
                                .font(.caption)

                        }
                    }
                    
                    HStack {
                        Image(systemName: "shield.checkerboard")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Grand exams:")
                                .font(.subheadline)
                                .bold()
                            Text("simulate real test conditions.")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "book")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("Curated notes:")
                                .font(.subheadline)
                                .bold()
                            Text("high-yield revision material.")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading) {
                            Text("Daily tips:")
                                .font(.subheadline)
                                .bold()
                            Text("enhance your study routine.")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Enroll Button
            Button(action: {
                // Enroll Action
            }) {
                Text("ENROLL NOW")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .edgesIgnoringSafeArea(.top) // To align animation to the top
        .background(Color(red: 1.0, green: 0.97, blue: 0.9)) // Background color to match the image
        .preferredColorScheme(.light) // Force light mode
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    
    func makeUIView(context: Context) -> some UIView {
        let view = LottieAnimationView(name: name)
        view.loopMode = .loop
        view.play()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Update the UIView when needed
    }
}

#Preview {
    Promo()
}
