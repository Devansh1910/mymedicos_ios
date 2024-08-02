import SwiftUI

struct LiveExaminationView: View {
    var body: some View {
        VStack {
            // Timer and status label
            HStack {
                Text("LIVE FOR 13 HRS 36 MIN 58 SEC")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.leading, 10)
                Spacer()
            }
            .padding(.top, 5)
            
            // Test details
            VStack(alignment: .leading, spacing: 10) {
                Text("FMGE Grand Test 06")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Text("300 Ques · 300 Mins")
                        .font(.subheadline)
                        Spacer()
                    Image(systemName: "trophy")
                        .foregroundColor(.blue)
                }
                .padding(.top, 5)
                
                // Participants
                HStack {
                    Text("648 are attempting")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.bottom, 5)
                
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            
            // Start button
            Button(action: {
                // Action for the button
            }) {
                Text("Start Test")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(Color.gray.opacity(0.1)) // Background color of the entire view
    }
}

struct LiveExaminationView_Previews: PreviewProvider {
    static var previews: some View {
        LiveExaminationView()
    }
}
