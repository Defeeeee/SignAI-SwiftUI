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

                // Headline text placed directly below logo
                VStack(alignment: .leading, spacing: 0) {
                    // Using custom Montserrat font - font weights require the appropriate Montserrat weights to be bundled in the project.
                    Text("Your free to use\nsign language translator.")
                        .font(Font.custom("Montserrat", size: 32).weight(.bold))
                        .foregroundColor(Color.orange)
                    (
                        Text("Powered by ")
                            .font(Font.custom("Montserrat", size: 32).weight(.regular))
                            .foregroundColor(Color(red: 0.77, green: 0.13, blue: 0.58))
                        +
                        Text("AI.")
                            .font(Font.custom("Montserrat", size: 32).weight(.regular))
                            .foregroundColor(Color.gray)
                    )
                }
                .padding(.horizontal, 32)

                // Buttons placed directly below the headline text
                HStack(spacing: 18) {
                    Button(action: { showUpload = true }) {
                        HStack {
                            Text("Start")
                                .font(Font.custom("Montserrat", size: 18).weight(.bold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(width: 120, height: 44)
                        .background(Color.orange)
                        .cornerRadius(22)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { /* Sign-in action */ }) {
                        HStack {
                            Text("Sign-in")
                                .font(Font.custom("Montserrat", size: 18).weight(.bold))
                            Image(systemName: "arrow.right")
                        }
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

                Spacer()
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
