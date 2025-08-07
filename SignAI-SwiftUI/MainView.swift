import SwiftUI

struct MainView: View {
    @State private var showUpload = false

    var body: some View {
        ZStack {
            // Gradient background with updated colors
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.white, location: 0),
                    .init(color: Color(red: 1, green: 0.73, blue: 0.27), location: 1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Logo centered horizontally
                HStack {
                    Image("SignAILOGO")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)

                HStack {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Headline text HStack
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Your free to use sign language translator.")
                                    .font(Font.custom("Montserrat", size: 30).weight(.bold))
                                    .foregroundColor(Color.orange)
                                ZStack(alignment: .leading) {
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#FF00A1"),
                                            Color(hex: "#FF3C00"),
                                            Color(hex: "#A100FF"),
                                            Color(hex: "#FFE100")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(height: 36)
                                    .mask(
                                        Text("Powered by AI.")
                                            .font(Font.custom("Montserrat", size: 30).weight(.bold))
                                            .fixedSize()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    )
                                }
                                .frame(height: 36, alignment: .leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // Buttons aligned leading with spacing and size
                            HStack(spacing: 16) {
                                Button(action: { showUpload = true }) {
                                    HStack {
                                        Text("Start")
                                            .font(Font.custom("Montserrat", size: 18).weight(.bold))
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 128, height: 44)
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
                                    .frame(width: 128, height: 44)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color.orange, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.top, 28)
                        }
                        .frame(maxWidth: 280, alignment: .leading)
                        .padding(.top, 48)

                        Spacer()
                    }
                    .padding(.leading, 64)
                    Spacer()
                }
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
