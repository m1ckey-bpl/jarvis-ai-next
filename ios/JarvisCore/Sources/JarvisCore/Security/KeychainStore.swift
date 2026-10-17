import Foundation
import Security

/// Secure wrapper around iOS Keychain for credential storage.
/// Service identifier: ai.jarvis.next
public final class KeychainStore {

    public static let shared = KeychainStore()
    private let service = "ai.jarvis.next"

    private init() {}

    // MARK: - Save

    @discardableResult
    public func save(key: String, value: String) throws -> Bool {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        // Delete existing first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
        return true
    }

    // MARK: - Load

    public func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    // MARK: - Delete

    @discardableResult
    public func delete(key: String) throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteFailed(status)
        }
        return true
    }

    // MARK: - Fingerprint (safe display)

    /// Returns the last 4 characters of the stored value for safe display. Never returns the full key.
    public func fingerprint(key: String) -> String? {
        guard let value = load(key: key), value.count >= 4 else { return nil }
        return "••••" + String(value.suffix(4))
    }

    // MARK: - Check existence

    public func exists(key: String) -> Bool {
        return load(key: key) != nil
    }
}

// MARK: - Errors

public enum KeychainError: Error, LocalizedError {
    case encodingFailed
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)

    public var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Failed to encode credential data."
        case .saveFailed(let s): return "Keychain save failed (OSStatus \(s))."
        case .deleteFailed(let s): return "Keychain delete failed (OSStatus \(s))."
        }
    }
}
