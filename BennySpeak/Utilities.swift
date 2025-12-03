//
//  Utilities.swift
//  BennySpeak
//
//  Created by James Lane on 11/13/25.
//

import AVFoundation

private enum Credentials {
    static func value(forKey key: String) -> String? {
        guard let url = Bundle.main.url(forResource: "Credentials", withExtension: "plist") else {
            print("[Credentials] Missing Credentials.plist in bundle.")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            if let dict = plist as? [String: Any], let value = dict[key] as? String, !value.isEmpty {
                return value
            } else {
                print("[Credentials] Key \(key) not found or empty in Credentials.plist.")
                return nil
            }
        } catch {
            print("[Credentials] Failed to load Credentials.plist: \(error)")
            return nil
        }
    }
}

var googleApiKey: String {
    if let v = Credentials.value(forKey: "GoogleApiKey") { return v }
    assertionFailure("googleApiKey missing from Credentials.plist")
    return ""
}

var googleSearchEngineId: String {
    if let v = Credentials.value(forKey: "googleSearchEngineId") { return v }
    assertionFailure("googleSearchEngineId missing from Credentials.plist")
    return ""
}

let kApiUrl = "https://customsearch.googleapis.com/customsearch/v1"

class Utilities {
    
    static let shared = Utilities()

    private let synthesizer = AVSpeechSynthesizer()
    private let preferredLanguageCode = "en-US"
    
    static func printPrettyJSON(_ data: Data) {
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .withoutEscapingSlashes])
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                print("\n===== JSON Response =====\n\(prettyString)\n==========================\n")
            } else {
                print("[PrettyPrint] Unable to encode JSON to UTF-8 string.")
            }
        } catch {
            if let raw = String(data: data, encoding: .utf8) {
                print("[PrettyPrint] Failed to pretty print JSON. Error: \(error)\nRaw response: \n\(raw)")
            } else {
                print("[PrettyPrint] Failed to pretty print JSON and could not decode raw data as UTF-8. Error: \(error)")
            }
        }
    }
    
    func speak(_ text: String) {
        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: text)
            
            // Try preferred voice first
            if let voice = AVSpeechSynthesisVoice(language: self.preferredLanguageCode) {
                utterance.voice = voice
            } else if let englishVoice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language.hasPrefix("en") }) {
                // Fall back to any English voice
                utterance.voice = englishVoice
            } else {
                // Leave voice unset to use system default; log available voices for debugging
                let available = AVSpeechSynthesisVoice.speechVoices().map { "\($0.name) [\($0.language)]" }
                print("Speech: No English voices available. Available voices: \(available)")
            }
            
            // Optional tuning (adjust as desired)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1.0
            utterance.postUtteranceDelay = 0.0
            
            self.synthesizer.speak(utterance)
        }
        
    }
    
}

