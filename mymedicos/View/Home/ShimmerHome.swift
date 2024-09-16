import SwiftUI

struct ShimmerHome: View {
    @State private var isAnimating = false

    let gradient = Gradient(colors: [.clear, .white.opacity(0.5), .clear])
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 300, height: 150)
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing))
                        .rotationEffect(.degrees(-30))
                        .offset(x: isAnimating ? 500 : -500)
                        .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                )
                .onAppear() {
                    self.isAnimating = true
                }
        }
    }
}

struct ShimmerHome_Previews: PreviewProvider {
    static var previews: some View {
        ShimmerHome()
    }
}
