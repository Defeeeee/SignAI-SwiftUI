import SwiftUI

enum NavigationDestination: Hashable {
    case upload, translation
}

struct SignAILogo: View {
    var body: some View {
        Image("SignAILOGO")
            .resizable()
            .scaledToFit()
            .frame(height: 48)
            .padding(.top, 24)
    }
}

struct TranslationResultView: View {
    let summary: String
    let translation: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(summary)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.85))
                .foregroundColor(.white)
                .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
            Text(translation)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .clipShape(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight]))
        }
        // Removed shadow to prevent black line
    }
}

struct TranslationView: View {
    let translation: String
    let title: String?
    let onNavToUpload: () -> Void
    let onNavToTranslation: () -> Void
    @State private var navigation: NavigationDestination? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                SignAILogo()
                    .frame(maxWidth: .infinity)
                VStack(spacing: 20) {
                    TranslationResultView(summary: title ?? "Summary", translation: translation)
                }
                .padding(.horizontal)
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        UploadBoxSmall()
                            .frame(maxWidth: 320)
                            .padding(.top, 24)
                        
                        Button(action: {}) {
                            Text("Choose file")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(height: 44)
                                .frame(maxWidth: 320)
                                .background(Color.orange)
                                .cornerRadius(22)
                        }
                        .padding(.top, 16)
                        
                        Text("or click on the coloured area")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .padding(.top, 6)
                    }
                    Spacer()
                }
                Spacer()
                
                BottomNavBar(
                    onHomeTap: onNavToUpload,
                    onProfileTap: onNavToTranslation
                )
            }
            .padding(.top, 8)
            .background(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .upload:
                    UploadView(onNavToTranslation: onNavToTranslation, onNavToUpload: onNavToUpload)
                        .navigationBarBackButtonHidden(true)
                case .translation:
                    TranslationView(
                        translation: translation,
                        title: title,
                        onNavToUpload: onNavToUpload,
                        onNavToTranslation: onNavToTranslation
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 16.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

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
                        .foregroundColor(Color.orange)
                )
            Image(systemName: "icloud.and.arrow.up")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(Color.orange)
        }
        .frame(maxWidth: 320)
    }
}

struct BottomNavBar: View {
    let onHomeTap: () -> Void
    let onProfileTap: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "gearshape")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
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
        .background(Color.orange.opacity(0.85))
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    TranslationView(
        translation: "On Tuesdays, the region is especially known for being more friendly and staying open longer, but also for having showers.",
        title: "Friendly tuesday",
        onNavToUpload: {},
        onNavToTranslation: {}
    )
}
