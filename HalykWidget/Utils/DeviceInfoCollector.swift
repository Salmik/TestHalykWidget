//
//  DeviceInfoCollector.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 05.09.2024.
//

import Foundation
import UIKit.UIDevice
import CryptoKit

struct DeviceInfoCollector {

    private static func getAppInstallationDate() -> Date {
        guard let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last,
              let folderPath = try? FileManager.default.attributesOfItem(atPath: documentsFolder.path),
              let installDate = folderPath[.creationDate] as? Date else {
            return Date()
        }

        return installDate
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func reduceTo16Bytes(hash: String) -> String {
        let hashBytes = stride(from: 0, to: hash.count, by: 2).compactMap { index -> UInt8? in
            let start = hash.index(hash.startIndex, offsetBy: index)
            let end = hash.index(start, offsetBy: 2)
            let byteString = String(hash[start..<end])
            return UInt8(byteString, radix: 16)
        }

        var reducedHash = [UInt8](repeating: 0, count: 16)

        for (i, byte) in hashBytes.enumerated() {
            let index = i % 16
            reducedHash[index] ^= byte
        }

        return reducedHash.map { String(format: "%02x", $0) }.joined(separator: ":")
    }

    static func deviceInfoHash() -> String {
        let osName = UIDevice.current.systemName
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let screenSize = "\(UIScreen.main.bounds.size.width)x\(UIScreen.main.bounds.size.height)"
        let deviceModel = UIDevice.current.model
        let installDate = getAppInstallationDate()
        let formattedInstallDate = formatDate(installDate)
        let manufacturer = "Apple"

        let combinedString = [
            manufacturer,
            deviceModel,
            osName,
            screenSize,
            formattedInstallDate,
            deviceID
        ].joined(separator: "|")

        let hashData = SHA256.hash(data: Data(combinedString.utf8))
        let hashString = hashData.compactMap { String(format: "%02x", $0) }.joined()

        return reduceTo16Bytes(hash: hashString)
    }
}
