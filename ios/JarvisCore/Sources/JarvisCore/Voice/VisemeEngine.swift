import Foundation

// MARK: - Viseme Engine

/// Maps spoken text to jaw-opening values for avatar lip synchronization.
/// Uses a vowel-dominant phoneme model — vowels drive the primary mouth shape.
public struct VisemeEngine {

    public enum Viseme: Double {
        case silence   = 0.0
        case rest      = 0.15
        case consonant = 0.30
        case dental    = 0.45
        case labial    = 0.55
        case open      = 0.70
        case wideOpen  = 0.85
    }

    /// Returns a single jaw-open value for a chunk of text (0.0 – 1.0).
    public static func jawOpen(for text: String) -> Double {
        let lower = text.lowercased()
        var totalWeight: Double = 0
        var totalChars: Double = 0
        for ch in lower {
            totalChars += 1
            switch ch {
            case "a", "e":          totalWeight += Viseme.wideOpen.rawValue
            case "i", "o", "u":    totalWeight += Viseme.open.rawValue
            case "m", "b", "p":    totalWeight += Viseme.labial.rawValue
            case "t", "d", "n",
                 "l", "s", "z":    totalWeight += Viseme.dental.rawValue
            case " ", ",", ".",
                 "!", "?", "\n":   totalWeight += Viseme.silence.rawValue
            default:               totalWeight += Viseme.consonant.rawValue
            }
        }
        guard totalChars > 0 else { return 0.0 }
        return min(1.0, totalWeight / totalChars)
    }

    /// Returns a sequence of (text chunk, jawOpen, duration) for timed animation.
    /// Duration is based on rough syllable count (≈ 0.12s per syllable).
    public static func phonemeSequence(for text: String) -> [(text: String, jawOpen: Double, duration: Double)] {
        let words = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        return words.map { word in
            let syllables = max(1, countSyllables(in: word))
            let duration = Double(syllables) * 0.12
            let jaw = jawOpen(for: word)
            return (text: word, jawOpen: jaw, duration: duration)
        }
    }

    // MARK: - Syllable counter (vowel-run heuristic)

    private static func countSyllables(in word: String) -> Int {
        let vowels = CharacterSet(charactersIn: "aeiouAEIOU")
        var count = 0
        var prevWasVowel = false
        for scalar in word.unicodeScalars {
            let isVowel = vowels.contains(scalar)
            if isVowel && !prevWasVowel { count += 1 }
            prevWasVowel = isVowel
        }
        // Silent 'e' at end
        if word.lowercased().hasSuffix("e") && count > 1 { count -= 1 }
        return max(1, count)
    }
}
