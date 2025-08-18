import SwiftUI
import PhotosUI
import Combine

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
    /// Updated API base
    let translateBase = "https://aiapi.signai.ar/predict_gemini?video_url="

    func processPicked(completion: @escaping (_ text: String, _ title: String, _ thumbnailURL: String?) -> Void) {
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

    private func uploadVideo(_ url: URL, completion: @escaping (_ text: String, _ title: String, _ thumbnailURL: String?) -> Void) async {
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

            let thumb = deriveCloudinaryThumbnail(fromSecureURL: secureUrl)

            await fetchTranslation(for: secureUrl) { text, title in
                completion(text, title, thumb)
            }
        } catch {
            statusMessage = nil
            showUploadingProgress = false
            showUploadingScreen = false
        }
    }

    private func fetchTranslation(for cloudinaryUrl: String, completion: @escaping (_ text: String, _ title: String) -> Void) async {
        statusMessage = "Awaiting translation response..."
        guard let url = URL(string: translateBase + (cloudinaryUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) else {
            statusMessage = nil
            showUploadingScreen = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let translationText = json["translation"] as? String {
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

    /// Cloudinary trick: insert `/so_1/` and convert to `.jpg`.
    private func deriveCloudinaryThumbnail(fromSecureURL secureUrl: String) -> String? {
        var result = secureUrl.replacingOccurrences(of: "/upload/", with: "/upload/so_1/")
        for ext in [".mp4", ".mov", ".m4v", ".webm"] {
            if result.lowercased().hasSuffix(ext) {
                result = String(result.dropLast(ext.count)) + ".jpg"
                return result
            }
        }
        return result + ".jpg"
    }
}
