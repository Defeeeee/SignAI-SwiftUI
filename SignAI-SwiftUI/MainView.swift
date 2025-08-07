import SwiftUI

enum Route: Hashable { case translation }

struct MainView: View {
    @State private var path: [Route] = []
    @State private var history: [TranslationPayload] = []

    var body: some View {
        NavigationStack(path: $path) {
            UploadView(
                onTranslationReady: { text, title, thumb in
                    history.append(.init(text: text, title: title ?? "Conversation", thumbnailURL: thumb))
                    if !path.contains(.translation) { path.append(.translation) }
                },
                onHomeTap: { path = [] },
                onProfileTap: { path = [.translation] },
                onSettingsTap: { }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .translation:
                    TranslationView(
                        translations: $history,
                        onHomeTap: { path = [] },
                        onProfileTap: { path = [.translation] },
                        onSettingsTap: { }
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview { MainView() }
