import SwiftUI

struct MainView: View {
    @State private var showUpload = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(red: 1, green: 0.68, blue: 0.22)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Logo at the very top with padding
                Image("SignAILOGO")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .padding(.top, 36)
                    .padding(.bottom, 24)

                Spacer()

                // Headline text vertically centered above buttons
                VStack(alignment: .leading, spacing: 0) {
                    // Using system font with weight .heavy because Font.custom weight is often ignored
                    // unless custom font files are correctly imported and registered.
                    Text("Your free to use\nsign language translator.")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(Color.orange)
                    (
                        Text("Powered by ")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(Color(red: 0.77, green: 0.13, blue: 0.58))
                        +
                        Text("AI.")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(Color.gray)
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                // Buttons placed visually in the lower third (not pinned)
                HStack(spacing: 18) {
                    Button(action: { showUpload = true }) {
                        HStack {
                            Text("Start")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 44)
                        .background(Color.orange)
                        .cornerRadius(22)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { /* Sign-in action */ }) {
                        HStack {
                            Text("Sign-in")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.orange)
                        .frame(width: 120, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 52)
            }
            .fullScreenCover(isPresented: $showUpload) {
                UploadView()
            }
        }
    }
}

#Preview {
    MainView()
}
