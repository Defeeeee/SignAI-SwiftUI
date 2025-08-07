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
            // Scrollable translation log (logo is fixed above)
            ScrollView {
                VStack(spacing: 16) {
                    // Keep content clear of the fixed logo height (12 + 32 + 12 = 56)
                    Color.clear.frame(height: 56)

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
                                    title: item.title,
                                    text: item.text,
                                    thumbnailURL: item.thumbnailURL
                                )
                                .padding(.horizontal)
                            }
                        }
                    }

                    // bottom padding so last card doesn't touch the pinned upload section
                    Color.clear.frame(height: 24)
                }
                .padding(.top, 8)
            }
            .background(Color.white)

            // Fixed top logo (same as upload view)
            TopLogoBar()
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
                    Color.clear.frame(height: 8)

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
            translations: .constant([
                .init(text: "On Tuesdays, the region is especially known...", title: "Friendly tuesday", thumbnailURL: "https://example.com/thumb.jpg")
            ]),
            onHomeTap: {},
            onProfileTap: {},
            onSettingsTap: {}
        )
    }
}
