//
//  RSAWorker.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 05.09.2024.
//

import Foundation
import CryptoKit
internal import HalykCore

protocol RSAService {
    func encrypt(_ string: String, publicKey: String) -> String?
}

class RSAWorker: RSAService {

    private func extractPublicKey(from publicKey: String) -> String? {
        let pattern: RegularExpression = #"[-]+BEGIN [^-]+[-]+\s*([A-Za-z0-9+/=\s]+?)\s*[-]+END [^-]+[-]+"#
        let key = pattern.firstMatch(in: publicKey, subgroupPosition: 1)
        return key?.replacingOccurrences(of: #"\s"#, with: "", options: .regularExpression)
    }

    private func createPublicKey(from publicKey: String) -> SecKey? {
        guard let data = Data(base64Encoded: publicKey) else { return nil }

        let attributes: CFDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: 2048
        ] as CFDictionary

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            if let error = error?.takeRetainedValue() {
                print("Error creating public key: \(error.localizedDescription)")
            }
            return nil
        }

        return secKey
    }

    private func encryptRSA(_ string: String, publicKey: SecKey) -> String? {
        let buffer = [UInt8](string.utf8)

        var keySize = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)

        let status = SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize)
        guard status == errSecSuccess else { return nil }
        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }

    func encrypt(_ string: String, publicKey: String) -> String? {
        guard let formattedKey = extractPublicKey(from: publicKey),
              let secKey = createPublicKey(from: formattedKey) else {
            return nil
        }
        return encryptRSA(string, publicKey: secKey)
    }
}
