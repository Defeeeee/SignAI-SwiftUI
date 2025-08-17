import SwiftUI
import PhotosUI

struct TranslationView: View {
    @Binding var translations: [TranslationPayload]

    let onHomeTap: () -> Void
    let onProfileTap: () -> Void
    let onSettingsTap: () -> Void

    @StateObject private var uploader = UploadManager()

    var body: some View {
        ZStack(alignment: .top) {
            // Scrollable translation log (logo fixed above)
            ScrollView {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 56) // room for TopLogoBar

                    if translations.isEmpty {
                        Text("No translations yet. Upload a video below to get started.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(translations.reversed()) { item in
                                TranslationCardView(
                                    cardId: item.id,
                                    title: item.title,
                                    text: item.text,
                                    thumbnailURL: item.thumbnailURL
                                )
                                .padding(.horizontal)
                            }
                        }
                    }

                    Color.clear.frame(height: 24) // keep away from upload area
                }
                .padding(.top, 8)
            }
            .background(Color.white)

            TopLogoBar() // fixed logo
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Color.clear.frame(height: 12)

                    UploadBoxSmall()
                        .onTapGesture { uploader.showPicker = true }
                        .padding(.horizontal)

                    Button {
                        uploader.showPicker = true
                    } label: {
                        Text(uploader.showUploadingProgress ? "Uploading…" : "Choose file")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.fromHex("#FF7A00"))
                            .cornerRadius(22)
                    }
                    .padding(.horizontal, 65)

                    VStack(spacing: 2) {
                        Text("or click on the coloured area")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)

                        if let status = uploader.statusMessage {
                            Text(status)
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.top, 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 8)
                }
                .background(Color.white)

                BottomNavBar(
                    onHomeTap: onHomeTap,
                    onProfileTap: onProfileTap,
                    onSettingsTap: onSettingsTap,
                    backgroundColor: Color.fromHex("#FF7A00")
                )
            }
            .zIndex(10)
        }
        .photosPicker(isPresented: $uploader.showPicker, selection: $uploader.selectedItem, matching: .videos)
        .onChange(of: uploader.selectedItem) { _ in
            uploader.processPicked { text, title, thumb in
                translations.append(.init(text: text, title: title, thumbnailURL: thumb))
            }
        }
        .overlay {
            if uploader.showUploadingScreen {
                UploadingProgressView(statusMessage: uploader.statusMessage)
            } else if uploader.showUploadingProgress {
                UploadingProgressView(statusMessage: uploader.statusMessage)
                    .opacity(0.98)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TranslationView(
            translations: .constant([]),
            onHomeTap: {},
            onProfileTap: {},
            onSettingsTap: {}
        )
    }
}
