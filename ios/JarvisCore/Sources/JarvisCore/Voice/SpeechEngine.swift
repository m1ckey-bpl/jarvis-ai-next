import Foundation
import AVFoundation
import Speech

// MARK: - Speech State

public enum SpeechState: Equatable {
    case idle
    case listening
    case speaking
    case error(String)
}

// MARK: - Speech Engine

/// Real-time voice input and output engine.
/// Input:  SFSpeechRecognizer (on-device, free)
/// Output: AVSpeechSynthesizer (on-device, free)
/// Both require physical device; Simulator microphone unavailable for recognition.
public final class SpeechEngine: NSObject, ObservableObject {

    // MARK: - Published state

    @Published public private(set) var state: SpeechState = .idle
    @Published public private(set) var transcribedText: String = ""
    @Published public private(set) var visemeIntensity: Double = 0.0
    @Published public private(set) var isSpeaking: Bool = false
    @Published public private(set) var isListening: Bool = false

    // MARK: - Private

    private let synthesizer = AVSpeechSynthesizer()
    private var recognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var visemeTimer: Timer?

    /// Called when recognition produces a final result.
    public var onTranscription: ((String) -> Void)?

    public override init() {
        super.init()
        synthesizer.delegate = self
        recognizer = SFSpeechRecognizer(locale: Locale.current)
    }

    // MARK: - Permissions

    public func requestPermissions() async -> Bool {
        let speechOK = await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
        let micOK = await withCheckedContinuation { cont in
            AVAudioApplication.requestRecordPermission { granted in
                cont.resume(returning: granted)
            }
        }
        return speechOK && micOK
    }

    // MARK: - Speech Recognition (Input)

    public func startListening() throws {
        guard state == .idle else { return }
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }

        stopSpeaking()

        let audioEngine = AVAudioEngine()
        self.audioEngine = audioEngine

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                if result.isFinal {
                    let final = result.bestTranscription.formattedString
                    DispatchQueue.main.async { self.stopListening() }
                    self.onTranscription?(final)
                }
            }
            if let error {
                DispatchQueue.main.async {
                    self.state = .error(error.localizedDescription)
                    self.stopListening()
                }
            }
        }

        DispatchQueue.main.async {
            self.state = .listening
            self.isListening = true
        }
    }

    public func stopListening() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        DispatchQueue.main.async {
            self.isListening = false
            if case .listening = self.state { self.state = .idle }
        }
    }

    // MARK: - Speech Synthesis (Output)

    public func speak(_ text: String) {
        guard !text.isEmpty else { return }
        stopListening()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.50
        utterance.pitchMultiplier = 0.95
        utterance.volume = 1.0

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {}

        DispatchQueue.main.async {
            self.state = .speaking
            self.isSpeaking = true
        }

        synthesizer.speak(utterance)
    }

    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.visemeIntensity = 0.0
            if case .speaking = self.state { self.state = .idle }
        }
        visemeTimer?.invalidate()
        visemeTimer = nil
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechEngine: AVSpeechSynthesizerDelegate {

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                   willSpeakRangeOfSpeechString characterRange: NSRange,
                                   utterance: AVSpeechUtterance) {
        guard let range = Range(characterRange, in: utterance.speechString) else { return }
        let chunk = String(utterance.speechString[range])
        let jaw = VisemeEngine.jawOpen(for: chunk)
        DispatchQueue.main.async { self.visemeIntensity = jaw }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                   didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.visemeIntensity = 0.0
            self.state = .idle
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                   didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.visemeIntensity = 0.0
            self.state = .idle
        }
    }
}

// MARK: - Errors

public enum SpeechError: Error, LocalizedError {
    case recognizerUnavailable
    case permissionDenied
    case audioEngineError(String)

    public var errorDescription: String? {
        switch self {
        case .recognizerUnavailable: return "Speech recognizer is not available on this device."
        case .permissionDenied: return "Microphone or speech recognition permission denied."
        case .audioEngineError(let e): return "Audio engine error: \(e)"
        }
    }
}
