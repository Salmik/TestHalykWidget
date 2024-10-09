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

        let hashData = CryptoKit.SHA256.hash(data: Data(combinedString.utf8))
        let byteArray = Array(hashData)
        let chunkedData = stride(from: 0, to: byteArray.count, by: 8).map { startIndex in
            Array(byteArray[startIndex..<min(startIndex + 8, byteArray.count)])
        }
        let reducedHash = chunkedData.map { chunk in
            chunk.reduce("") { $0 + String(format: "%02x", $1) }
        }

        return reducedHash.joined(separator: ":")
    }
}
