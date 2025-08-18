import SwiftUI
import AVFoundation
import Combine

@MainActor
final class SpeechCenter: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var currentId: UUID? = nil
    @Published var isSpeaking: Bool = false
    @Published var isPaused: Bool = false

    private let synth = AVSpeechSynthesizer()

    override init() {
        super.init()
        synth.delegate = self
    }

    // Use a session that is captured by screen recording and routes to speaker.
    private func activateAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothHFP, .allowBluetoothA2DP]
            )
            try session.setActive(true, options: [])
        } catch { }
    }

    private func deactivateAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do { try session.setActive(false, options: [.notifyOthersOnDeactivation]) } catch { }
    }

    func speak(text: String, for id: UUID, locale: String = "en-US") {
        if currentId == id, isSpeaking, !isPaused { pause(); return }
        if currentId == id, isPaused { resume(); return }

        stop()
        activateAudioSession()

        let utt = AVSpeechUtterance(string: text)
        utt.voice = AVSpeechSynthesisVoice(language: locale)
        utt.rate = 0.48
        utt.pitchMultiplier = 1.0
        utt.postUtteranceDelay = 0.0

        currentId = id
        synth.speak(utt)
    }

    func pause() {
        guard synth.isSpeaking else { return }
        synth.pauseSpeaking(at: .word)
        isPaused = true
    }

    func resume() {
        guard isPaused else { return }
        synth.continueSpeaking()
        isPaused = false
    }

    func stop() {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        isSpeaking = false
        isPaused = false
        currentId = nil
        deactivateAudioSession()
    }

    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
        isPaused = false
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) { stop() }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { stop() }
}
