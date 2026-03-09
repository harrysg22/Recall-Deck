//
//  YandexDictionaryService.swift
//  CardsApp
//

import Foundation

struct YandexLookupResponse: Codable {
    let def: [YandexDefinition]?
}

struct YandexDefinition: Codable {
    let text: String?
    let pos: String?
    let tr: [YandexTranslation]?
}

struct YandexTranslation: Codable {
    let text: String?
    let pos: String?
    let gen: String?
    let ex: [YandexExample]?
}

struct YandexExample: Codable {
    let text: String?
    let tr: [YandexExampleTr]?
}

struct YandexExampleTr: Codable {
    let text: String?
}

final class YandexDictionaryService {
    private let baseURL = "https://dictionary.yandex.net/api/v1/dicservice.json"
    private let session = URLSession.shared

    func lookup(word: String, from sourceLang: String, to targetLang: String, apiKey: String) async throws -> (translation: String, transcription: String?, example: String?) {
        guard !apiKey.isEmpty else {
            throw YandexError.missingAPIKey
        }
        let pair = "\(sourceLang)-\(targetLang)"
        var components = URLComponents(string: "\(baseURL)/lookup")!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "lang", value: pair),
            URLQueryItem(name: "text", value: word),
        ]
        guard let url = components.url else {
            throw YandexError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw YandexError.serverError
        }
        let decoded = try JSONDecoder().decode(YandexLookupResponse.self, from: data)
        guard let def = decoded.def?.first, let firstTr = def.tr?.first else {
            throw YandexError.noTranslation
        }
        let translation = firstTr.text ?? ""
        let transcription = def.text
        let example: String? = firstTr.ex?.first.flatMap { ex in
            let s = [ex.text, ex.tr?.first?.text].compactMap { $0 }.joined(separator: " — ")
            return s.isEmpty ? nil : s
        }
        return (translation, transcription, example)
    }

    enum YandexError: LocalizedError {
        case missingAPIKey
        case invalidURL
        case serverError
        case noTranslation
        var errorDescription: String? {
            switch self {
            case .missingAPIKey: return "Introduce tu clave API en Ajustes."
            case .invalidURL: return "URL no válida."
            case .serverError: return "Error del servidor. Comprueba la clave API y el par de idiomas."
            case .noTranslation: return "No se encontró traducción para esta palabra."
            }
        }
    }
}
