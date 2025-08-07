import SwiftUI
import PhotosUI

struct UploadView: View {
  @State private var selectedVideo: PhotosPickerItem? = nil
  @State private var isUploading = false
  @State private var errorMessage: String? = nil
  @State private var statusMessage: String? = nil
  @State private var videoUrl: URL? = nil
  @State private var showTranslation = false
  @State private var translationText: String? = nil
  @State private var summaryTitle: String? = nil
  @State private var showUploadingScreen = false
  @State private var isAwaitingTranslation = false
  @State private var showUploadingProgress = false
  
  let onNavToTranslation: () -> Void
  let onNavToUpload: () -> Void

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        // Logo at the top
        Image("SignAILOGO")
          .resizable()
          .scaledToFit()
          .frame(height: 32)
          .padding(.top, 36)
          .padding(.bottom, 16)
        // Upload prompt
        HStack {
          Text("Click here to upload your video")
            .font(Font.custom("Montserrat", size: 29).weight(.bold))
            .foregroundColor(Color(red: 1, green: 0.48, blue: 0))
          Spacer()
        }
        .padding(.horizontal, 32)
        // Glass container for upload area and nav bar
        GlassEffectContainer(spacing: 40) {
          VStack(spacing: 0) {
            // Upload area with Liquid Glass wrapped in PhotosPicker
            PhotosPicker(selection: $selectedVideo, matching: .videos, photoLibrary: .shared()) {
              ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                  .fill(
                    LinearGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.82, blue: 0.77), Color(red: 1, green: 0.96, blue: 0.78), Color(red: 1, green: 0.79, blue: 0.56)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                  )
                  .frame(width: 343, height: 343)
                  .overlay(
                    RoundedRectangle(cornerRadius: 20)
                      .stroke(style: StrokeStyle(lineWidth: 3, dash: [10]))
                      .foregroundColor(Color(red: 1, green: 0.48, blue: 0))
                  )
                Image(systemName: "icloud.and.arrow.up")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 48, height: 48)
                  .foregroundColor(Color(red: 1, green: 0.48, blue: 0))
              }
              .padding(.top, 16)
            }
            .buttonStyle(.plain)
            // Choose file button
            PhotosPicker(selection: $selectedVideo, matching: .videos, photoLibrary: .shared()) {
              Text("Choose file")
                .font(Font.custom("Inter", size: 16).weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(red: 1, green: 0.48, blue: 0))
                .cornerRadius(22)
            }
            .padding(.horizontal, 65)
            .padding(.top, 28)
            // Helper text
            Text("or click on the coloured area")
              .font(Font.custom("Montserrat", size: 10).weight(.light))
              .foregroundColor(.gray)
              .padding(.top, 8)
            
            if let status = statusMessage {
              Text(status)
                .font(Font.custom("Montserrat", size: 14).weight(.medium))
                .foregroundColor(Color.gray)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
          }
          Spacer()
          // Bottom navigation bar with Liquid Glass
          HStack(spacing: 0) {
            Spacer()
            Image(systemName: "gearshape")
              .resizable()
              .scaledToFit()
              .frame(width: 24, height: 24)
              .foregroundColor(.white)
            Spacer()
            Button(action: onNavToUpload) {
              Image(systemName: "house")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
            }
            Spacer()
            Button(action: onNavToTranslation) {
              Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
            }
            Spacer()
          }
          .frame(height: 60)
          .background(Color(red: 1, green: 0.48, blue: 0).opacity(0.85))
          .glassEffect(.regular, in: .rect(cornerRadius: 0))
        }
        .onChange(of: selectedVideo) { newValue in
          guard let item = newValue else { return }
          statusMessage = "Video received. Preparing upload..."
          errorMessage = nil
          showUploadingProgress = true
          showUploadingScreen = false
          Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
              errorMessage = "Could not load video data."
              statusMessage = nil
              showUploadingProgress = false
              showUploadingScreen = false
              return
            }
            let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            do {
              try data.write(to: tempUrl)
            } catch {
              errorMessage = "Failed to save temporary video file."
              statusMessage = nil
              showUploadingProgress = false
              showUploadingScreen = false
              return
            }
            await uploadVideo(tempUrl)
          }
        }
      }
      
      if showUploadingScreen {
        Color(red: 1, green: 0.48, blue: 0)
          .ignoresSafeArea()
          .overlay(
            VStack {
              Spacer().frame(height: 36)
              Image("SignAILOGO")
                .resizable()
                .scaledToFit()
                .frame(height: 32)
                .padding(.bottom, 32)
              HStack {
                Text("Click here to upload your video")
                  .font(Font.custom("Montserrat", size: 29).weight(.bold))
                  .foregroundColor(Color(red: 1, green: 0.48, blue: 0))
                Spacer()
              }
              .padding(.horizontal, 32)
              Spacer().frame(height: 36)
              ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                  .fill(
                    LinearGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.82, blue: 0.77), Color(red: 1, green: 0.96, blue: 0.78), Color(red: 1, green: 0.79, blue: 0.56)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                  )
                  .frame(width: 343, height: 343)
                VStack(spacing: 24) {
                  SpinningIcon()
                    .frame(width: 120, height: 120)
                    .padding(.top, 16)
                  Text("Loading translation...")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 24)
                }
              }
              .padding(.top, 0)
              Spacer()
              /*
              // Bottom navigation bar with Liquid Glass, orange and simplified icons
              HStack(spacing: 0) {
                Spacer()
                Image(systemName: "gearshape")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 24, height: 24)
                  .foregroundColor(.white)
                Spacer()
                Image(systemName: "house")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 24, height: 24)
                  .foregroundColor(.white)
                Spacer()
                Image(systemName: "person.circle")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 24, height: 24)
                  .foregroundColor(.white)
                Spacer()
              }
              .frame(height: 60)
              .background(Color(red: 1, green: 0.48, blue: 0).opacity(0.85))
              .glassEffect(.regular, in: .rect(cornerRadius: 0))
              */
            }
          )
      }
      
      if showUploadingProgress && !showUploadingScreen {
        UploadingProgressView(statusMessage: statusMessage)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
    .alert("Error", isPresented: Binding<Bool>(
      get: { errorMessage != nil },
      set: { if !$0 { errorMessage = nil } }
    ), actions: {
      Button("OK", role: .cancel) {
        errorMessage = nil
        showUploadingScreen = false
        showUploadingProgress = false
      }
    }, message: {
      if let message = errorMessage {
        Text(message)
      }
    })
    .fullScreenCover(isPresented: $showTranslation) {
      if let translation = translationText {
        TranslationView(translation: translation, title: summaryTitle ?? "Conversation", onNavToUpload: {}, onNavToTranslation: {})
      }
    }
    // Note: TranslationView must accept a 'title' parameter of type String?
  }

  func uploadVideo(_ url: URL) async {
    await MainActor.run {
      showUploadingProgress = true
      showUploadingScreen = false
      statusMessage = "Uploading video..."
    }
    guard let videoData = try? Data(contentsOf: url) else {
      await MainActor.run {
        errorMessage = "Could not read video data."
        statusMessage = nil
        showUploadingProgress = false
        showUploadingScreen = false
      }
      return
    }
    var request = URLRequest(url: URL(string: "https://api.cloudinary.com/v1_1/dzonya1wx/video/upload")!)
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
    body.append("signai\r\n".data(using: .utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    request.httpBody = body
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let url = json["secure_url"] as? String {
        await MainActor.run {
          statusMessage = "Video uploaded. Sending to AI..."
          showUploadingProgress = false
          showUploadingScreen = true
        }
        await fetchTranslation(for: url)
      } else {
        let responseString = String(data: data, encoding: .utf8) ?? "<unable to decode response>"
        await MainActor.run {
          errorMessage = "Upload failed: Invalid response: \(responseString)"
          statusMessage = nil
          showUploadingProgress = false
          showUploadingScreen = false
        }
      }
    } catch {
      await MainActor.run {
        errorMessage = "Upload failed: \(error.localizedDescription)"
        statusMessage = nil
        showUploadingProgress = false
        showUploadingScreen = false
      }
    }
  }

  func fetchTranslation(for cloudinaryUrl: String) async {
    await MainActor.run {
      statusMessage = "Awaiting translation response..."
    }
    guard let url = URL(string: "https://signai.fdiaznem.com.ar/predict_gemini?video_url=\(cloudinaryUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
      await MainActor.run {
        statusMessage = nil
        showUploadingScreen = false
        showUploadingProgress = false
      }
      return
    }
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
         let translationText = json["translation"] as? String {
        let summary = json["summary"] as? String
        await MainActor.run {
          self.translationText = translationText
          self.summaryTitle = summary
          self.showTranslation = true
          self.statusMessage = nil
          self.showUploadingScreen = false
          self.showUploadingProgress = false
        }
      } else {
        let responseString = String(data: data, encoding: .utf8) ?? "<unable to decode response>"
        await MainActor.run {
          errorMessage = "Translation fetch failed: Invalid response: \(responseString)"
          statusMessage = nil
          showUploadingScreen = false
          showUploadingProgress = false
        }
      }
    } catch {
      await MainActor.run {
        errorMessage = "Translation fetch failed: \(error.localizedDescription)"
        statusMessage = nil
        showUploadingScreen = false
        showUploadingProgress = false
      }
    }
  }
}

struct UploadView_Previews: PreviewProvider {
  static var previews: some View {
    UploadView(onNavToTranslation: {}, onNavToUpload: {})
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
        withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
          rotation = 360
        }
      }
  }
}

struct UploadingProgressView: View {
  let statusMessage: String?
  var body: some View {
    Color(red: 1, green: 0.48, blue: 0)
      .ignoresSafeArea()
      .overlay(
        ZStack {
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
              LinearGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.82, blue: 0.77), Color(red: 1, green: 0.96, blue: 0.78), Color(red: 1, green: 0.79, blue: 0.56)]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
