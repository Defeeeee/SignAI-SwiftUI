import SwiftUI
import Combine

/// Translation card with left thumbnail and dynamic height,
/// rounded white TTS controls (icons in #FFA369).
struct TranslationCardView: View {
    let cardId: UUID
    let title: String
    let text: String
    let thumbnailURL: String?

    @EnvironmentObject private var speech: SpeechCenter

    private let cardCorner: CGFloat = 16
    private let thumbWidth: CGFloat = 120
    private let iconOrange = Color.fromHex("#FFA369")

    @State private var contentHeight: CGFloat = 160 // will match content

    var body: some View {
        HStack(spacing: 0) {
            // Thumbnail matches the measured height on the right
            thumbnail
                .frame(width: thumbWidth, height: contentHeight)
                .clipped()
                .clipShape(RoundedCorner(radius: cardCorner, corners: [.topLeft, .bottomLeft]))

            // Title + text + TTS controls
            rightContent
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCorner, style: .continuous))
    }

    private var thumbnail: some View {
        Group {
            if let urlStr = thumbnailURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure(_): Color.black.opacity(0.05).overlay(Image(systemName: "photo").imageScale(.large))
                    case .empty: Color.black.opacity(0.05)
                    @unknown default: Color.black.opacity(0.05)
                    }
                }
            } else {
                Color.black.opacity(0.05).overlay(Image(systemName: "photo").imageScale(.large))
            }
        }
    }

    private var rightContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()

                // Rounded white TTS control
                Button {
                    speech.speak(text: text, for: cardId)
                } label: {
                    Image(systemName:
                            (speech.currentId == cardId && speech.isSpeaking && !speech.isPaused)
                            ? "pause.fill"
                            : (speech.currentId == cardId && speech.isPaused)
                            ? "play.fill"
                            : "speaker.wave.2.fill"
                    )
                    .foregroundColor(iconOrange)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                }

                // Stop button
                Button {
                    if speech.currentId == cardId { speech.stop() }
                } label: {
                    Image(systemName: "stop.fill")
                        .foregroundColor(iconOrange)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.fromHex("#FFA369"))

            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(.black)
                .background(Color.fromHex("#EEEEEE"))
        }
        // Measure and sync the height to thumbnail
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { contentHeight = max(geo.size.height, 120) }
                    .onChange(of: geo.size.height) { newValue in
                        contentHeight = max(newValue, 120)
                    }
            }
        )
    }
}
