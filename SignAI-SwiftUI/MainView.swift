import SwiftUI

enum Route: Hashable { case translation }

struct MainView: View {
    @State private var path: [Route] = []
    @State private var history: [TranslationPayload] = []

    var body: some View {
        NavigationStack(path: $path) {
            UploadView(
                onTranslationReady: { text, title in
                    history.append(.init(text: text, title: title ?? "Conversation"))
                    if !path.contains(.translation) { path.append(.translation) }
                },
                onHomeTap: { path = [] },
                onProfileTap: {
                    // Always navigate to Translation, even if history is empty.
                    path = [.translation]
                },
                onSettingsTap: {
                    // hook up settings later if you want
                }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .translation:
                    TranslationView(
                        translations: $history,
                        onHomeTap: { path = [] },
                        onProfileTap: { path = [.translation] },
                        onSettingsTap: { /* settings later */ }
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview { MainView() }

extension Color {
    init(hex: String) {
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
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
