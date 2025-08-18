import SwiftUI

// MARK: - Top bar

struct TopLogoBar: View {
    private let topPadding: CGFloat = 12
    private let logoHeight: CGFloat = 32
    private let bottomPadding: CGFloat = 12

    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topPadding)
            Image("SignAILOGO")
                .resizable()
                .scaledToFit()
                .frame(height: logoHeight)
            Color.clear.frame(height: bottomPadding)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

// MARK: - Upload box

struct UploadBoxSmall: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1, green: 0.82, blue: 0.77),
                            Color(red: 1, green: 0.96, blue: 0.78),
                            Color(red: 1, green: 0.79, blue: 0.56)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .foregroundColor(Color.fromHex("#FF7A00"))
                )
            Image(systemName: "icloud.and.arrow.up")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(Color.fromHex("#FF7A00"))
        }
        .frame(maxWidth: 320)
    }
}

// MARK: - Bottom nav bar

struct BottomNavBar: View {
    let onHomeTap: () -> Void
    let onProfileTap: () -> Void
    let onSettingsTap: () -> Void
    var backgroundColor: Color = Color.fromHex("#FF7A00")

    var body: some View {
        HStack {
            Spacer()
            Button(action: onSettingsTap) {
                Image(systemName: "gearshape")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: onHomeTap) {
                Image(systemName: "house")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: onProfileTap) {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .frame(height: 60)
        .background(backgroundColor)
        .ignoresSafeArea(edges: .bottom)
        .zIndex(10)
    }
}

// MARK: - Progress overlay

struct SpinningIcon: View {
    @State private var rotation: Double = 0
    var body: some View {
        Image("signaiicon")
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

struct UploadingProgressView: View {
    let statusMessage: String?
    var body: some View {
        Color.fromHex("#FF7A00")
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1, green: 0.82, blue: 0.77),
                                    Color(red: 1, green: 0.96, blue: 0.78),
                                    Color(red: 1, green: 0.79, blue: 0.56)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 343, height: 343)
                    VStack(spacing: 24) {
                        SpinningIcon()
                            .frame(width: 120, height: 120)
                            .padding(.top, 16)
                        Text(statusMessage ?? "Uploading...")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.top, 24)
                    }
                }
            )
    }
}
