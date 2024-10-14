//
//  CommonInformation.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 03.10.2024.
//

import Foundation
import WebKit
internal import HalykCore

public class CommonInformation {

    public static let shared = CommonInformation()
    private let networkWorker = NetworkWorker()
    private init() {}

    // Parnters info
    var partnerUserName = ""
    var partnerPassword = ""
    var partnersToken: String?

    var serverTime: String?
    var publicKey: String?
    var rootToken: String?
    var tokenPair: TokenPair?

    public private(set) var processes: [Processes] = []

    private func clearCache(for domain: String) {
        let dataStore = WKWebsiteDataStore.default()
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()

        dataStore.fetchDataRecords(ofTypes: websiteDataTypes) { records in
            let recordsToDelete = records.filter { $0.displayName.contains(domain) }

            dataStore.removeData(ofTypes: websiteDataTypes, for: recordsToDelete) {
                Logger.print("Кэш для был очищен.")
            }
        }
    }

    public func logout() {
        clearCache(for: "baas-test.halykbank.kz")
        let _ = try? KeychainService().delete(key: KeychainKeys.rootToken)
    }

    public func setPartnersInfo(login: String, password: String, completion: @escaping ([Processes]?) -> Void) {
        Task(priority: .userInitiated) {
            CommonInformation.shared.partnerUserName = login
            CommonInformation.shared.partnerPassword = password

            await networkWorker.getTokenPair()

            if let dictionaries = await networkWorker.getServices() {
                DispatchQueue.main.async {
                    self.processes = dictionaries.processes ?? []
                    completion(dictionaries.processes)
                }
            }
        }
    }
}
