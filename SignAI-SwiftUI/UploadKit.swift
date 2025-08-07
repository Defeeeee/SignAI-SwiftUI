import SwiftUI
import PhotosUI
import Combine

// MARK: - Helpers

extension Color {
    /// Conflict-free hex factory (avoid init ambiguity)
    static func fromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(.sRGB,
                     red: Double(r) / 255,
                     green: Double(g) / 255,
                     blue: Double(b) / 255,
                     opacity: Double(a) / 255)
    }
}

// MARK: - Models

struct TranslationPayload: Hashable, Identifiable {
    var id = UUID()
    let text: String
    let title: String
}

// MARK: - Uploader (shared logic)

@MainActor
final class UploadManager: ObservableObject {
    // UI state
    @Published var showPicker = false
    @Published var selectedItem: PhotosPickerItem? = nil
    @Published var statusMessage: String? = nil
    @Published var showUploadingScreen = false
    @Published var showUploadingProgress = false

    // Endpoints / config
    let cloudinaryURL = URL(string: "https://api.cloudinary.com/v1_1/dzonya1wx/video/upload")!
    let uploadPreset = "signai"
    let translateBase = "https://signai.fdiaznem.com.ar/predict_gemini?video_url="

    func processPicked(completion: @escaping (_ text: String, _ title: String) -> Void) {
        guard let item = selectedItem else { return }
        statusMessage = "Video received. Preparing upload..."
        showUploadingProgress = true
        showUploadingScreen = false

        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                self.statusMessage = nil
                self.showUploadingProgress = false
                self.showUploadingScreen = false
                return
            }
            let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            do { try data.write(to: tempUrl) } catch {
                self.statusMessage = nil
                self.showUploadingProgress = false
                self.showUploadingScreen = false
                return
            }
            await self.uploadVideo(tempUrl, completion: completion)
        }
    }

    private func uploadVideo(_ url: URL, completion: @escaping (_ text: String, _ title: String) -> Void) async {
        statusMessage = "Uploading video..."
        showUploadingProgress = true

        guard let videoData = try? Data(contentsOf: url) else {
            statusMessage = nil
            showUploadingProgress = false
            return
        }

        var request = URLRequest(url: cloudinaryURL)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"video.mov\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/quicktime\r\n\r\n".data(using: .utf8)!)
        body.append(videoData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let secureUrl = json["secure_url"] as? String
            else {
                statusMessage = nil
                showUploadingProgress = false
                return
            }
            statusMessage = "Video uploaded. Sending to AI..."
            showUploadingProgress = false
            showUploadingScreen = true
            await fetchTranslation(for: secureUrl, completion: completion)
        } catch {
            statusMessage = nil
            showUploadingProgress = false
            showUploadingScreen = false
        }
    }

    private func fetchTranslation(for cloudinaryUrl: String, completion: @escaping (_ text: String, _ title: String) -> Void) async {
        statusMessage = "Awaiting translation response..."
        guard
            let url = URL(string: translateBase + (cloudinaryUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))
        else {
            statusMessage = nil
            showUploadingScreen = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let translationText = json["translation"] as? String
            {
                let summary = (json["summary"] as? String) ?? "Conversation"
                statusMessage = "Rendering translation..."
                showUploadingScreen = false
                completion(translationText, summary)
                statusMessage = nil
            } else {
                statusMessage = nil
                showUploadingScreen = false
            }
        } catch {
            statusMessage = nil
            showUploadingScreen = false
        }
    }
}

// MARK: - Shared UI

/// Fixed top logo bar (same size/position across screens)
struct TopLogoBar: View {
    private let topPadding: CGFloat = 12     // closer to top than before
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

struct TranslationResultView: View {
    let summary: String
    let translation: String
    var titleColor: Color = Color.fromHex("#FFA369")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(summary)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(titleColor)
                .foregroundColor(.white)
                .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
            Text(translation)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.fromHex("#EEEEEE"))
                .foregroundColor(.black)
                .clipShape(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight]))
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
