//
//  TTSService.swift
//  CardsApp
//

import AVFoundation
import Foundation

final class TTSService: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var completion: (() -> Void)?

    /// Activa la sesión de audio (necesario en dispositivo real; en simulador a veces funciona sin esto).
    private func activateAudioSessionIfNeeded() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // En dispositivo, sin esto el TTS puede no sonar
            #if DEBUG
            print("TTSService: no se pudo activar sesión de audio: \(error)")
            #endif
        }
    }

    /// Maps deck language code to AVSpeechSynthesisVoice language identifier (e.g. "zh" -> "zh-CN")
    static func voiceLanguage(for langCode: String) -> String {
        switch langCode.lowercased() {
        case "zh": return "zh-CN"
        case "en": return "en-US"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "pt": return "pt-BR"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "ru": return "ru-RU"
        case "ar": return "ar-SA"
        default: return langCode
        }
    }

    /// Speech rate 0...1 (0.5 = default). Stored in UserDefaults as Double.
    var rate: Float {
        let stored = UserDefaults.standard.double(forKey: "speechRate")
        if stored == 0 { return 0.5 }
        return Float(stored)
    }

    func speak(word: String, example: String?, language: String) {
        stop()
        activateAudioSessionIfNeeded()
        let lang = Self.voiceLanguage(for: language)
        let voice = AVSpeechSynthesisVoice(language: lang) ?? AVSpeechSynthesisVoice(language: "en-US")
        let utteranceWord = AVSpeechUtterance(string: word)
        utteranceWord.voice = voice
        utteranceWord.rate = rate
        synthesizer.speak(utteranceWord)
        if let ex = example, !ex.isEmpty {
            let utteranceEx = AVSpeechUtterance(string: ex)
            utteranceEx.voice = voice
            utteranceEx.rate = rate
            synthesizer.speak(utteranceEx)
        }
    }

    func speak(text: String, language: String) {
        stop()
        activateAudioSessionIfNeeded()
        let lang = Self.voiceLanguage(for: language)
        let voice = AVSpeechSynthesisVoice(language: lang) ?? AVSpeechSynthesisVoice(language: "en-US")
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = rate
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }
}
