import SwiftUI
import PhotosUI

struct UploadView: View {
    @StateObject private var uploader = UploadManager()

    let onTranslationReady: (_ text: String, _ title: String?, _ thumbnailURL: String?) -> Void
    let onHomeTap: () -> Void
    let onProfileTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TopLogoBar()

                HStack {
                    Text("Click here to upload your video")
                        .font(Font.custom("Montserrat", size: 29).weight(.bold))
                        .foregroundColor(Color.fromHex("#FF7A00"))
                    Spacer()
                }
                .padding(.horizontal, 32)

                VStack(spacing: 40) {
                    VStack(spacing: 0) {
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [10]))
                                        .foregroundColor(Color.fromHex("#FF7A00"))
                                )
                            Image(systemName: "icloud.and.arrow.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .foregroundColor(Color.fromHex("#FF7A00"))
                        }
                        .padding(.top, 16)
                        .contentShape(Rectangle())
                        .onTapGesture { uploader.showPicker = true }

                        Button {
                            uploader.showPicker = true
                        } label: {
                            Text("Choose file")
                                .font(Font.custom("Inter", size: 16).weight(.bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.fromHex("#FF7A00"))
                                .cornerRadius(22)
                        }
                        .padding(.horizontal, 65)
                        .padding(.top, 28)

                        Text("or click on the coloured area")
                            .font(Font.custom("Montserrat", size: 10).weight(.light))
                            .foregroundColor(.gray)
                            .padding(.top, 8)

                        if let status = uploader.statusMessage {
                            Text(status)
                                .font(Font.custom("Montserrat", size: 14).weight(.medium))
                                .foregroundColor(Color.gray)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                    }

                    Spacer(minLength: 0)

                    BottomNavBar(
                        onHomeTap: onHomeTap,
                        onProfileTap: onProfileTap,
                        onSettingsTap: onSettingsTap,
                        backgroundColor: Color.fromHex("#FF7A00")
                    )
                }
                .padding(.top, 8)
            }
            .background(Color.white)

            if uploader.showUploadingScreen {
                UploadingProgressView(statusMessage: uploader.statusMessage)
            } else if uploader.showUploadingProgress {
                UploadingProgressView(statusMessage: uploader.statusMessage)
                    .opacity(0.98)
            }
        }
        .photosPicker(isPresented: $uploader.showPicker, selection: $uploader.selectedItem, matching: .videos)
        .onChange(of: uploader.selectedItem) { _ in
            uploader.processPicked { text, title, thumb in
                onTranslationReady(text, title, thumb)
            }
        }
    }
}
