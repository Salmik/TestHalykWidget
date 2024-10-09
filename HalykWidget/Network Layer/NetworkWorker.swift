//
//  AuthorizationNetworkWorker.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 26.09.2024.
//

import Foundation
internal import HalykCore

class NetworkWorker {

    enum KeychainKeys: String, KeychainKeyProtocol { case rootToken }

    private lazy var networkManager: NetworkManager = {
        let networkManager = NetworkManager()
        networkManager.isNeedToLogRequests = true
        return networkManager
    }()
    private let keychainManager = KeychainService()
    private let rsaWorker = RSAWorker()
    private let jsonWorker = JSONWorker()

    func getPartnerToken(login: String, password: String) async -> String? {
        return await networkManager.request(
            HalykWidgetAuthorizationApi.partnerToken(login: login, password: password)
        )?.json?["token"] as? String
    }

    func getServerTime() async -> String? {
        return await networkManager.request(HalykWidgetAuthorizationApi.serverTime)?.json?["server_time"] as? String
    }

    func getPublicKey() async -> String? {
        guard let partnerToken = CommonInformation.shared.partnersToken else {
            Logger.print("Partner token is not set")
            return nil
        }
        return await networkManager.request(
            HalykWidgetAuthorizationApi.publicKey(partnerToken: partnerToken)
        )?.json?["key"] as? String
    }

    func getRootToken() async -> String? {
        if let data = try? keychainManager.load(key: KeychainKeys.rootToken) {
            return String(data: data, encoding: .utf8)
        } else {
            guard let partnerToken = CommonInformation.shared.partnersToken else {
                Logger.print("Partner token is not set")
                return nil
            }

            let rootModel = RootTokenModel(
                partnerToken: partnerToken,
                fingerPrint: DeviceInfoCollector.deviceInfoHash(),
                body: .init(user_name: "123", password: "123")
            )
            guard let rootToken = await networkManager.request(
                HalykWidgetAuthorizationApi.rootToken(info: rootModel)
            )?.json?["root_token"] as? String else { return nil }

            let _ = try? keychainManager.save(key: KeychainKeys.rootToken, data: Data(rootToken.utf8))

            return rootToken
        }
    }

    func getTokenPair() async -> TokenPair? {
        guard let rootToken = CommonInformation.shared.rootToken,
              let partnerToken = CommonInformation.shared.partnersToken else {
            return nil
        }

        let recievedServerTime: String
        let recievedPublicKey: String

        if let serverTime = CommonInformation.shared.serverTime {
            recievedServerTime = serverTime
        } else {
            recievedServerTime = await getServerTime() ?? ""
        }

        if let publicKey = CommonInformation.shared.publicKey {
            recievedPublicKey = publicKey
        } else {
            recievedPublicKey = await getPublicKey() ?? ""
        }

        let tokepairBody = TokenPairModel(
            root_token: rootToken,
            device_id: DeviceInfoCollector.deviceInfoHash(),
            expires_at: TimeStampCalculator.callculate(from: recievedServerTime),
            salt: "some salt"
        )
        let json = jsonWorker.makeJSon(from: tokepairBody)
        let encodedJson = rsaWorker.encrypt(json, publicKey: recievedPublicKey) ?? ""
        let tokenBody = TokenPairBody(auth_token: encodedJson, user_name: "User name")
        let response = await networkManager.request(
            HalykWidgetAuthorizationApi.tokenPair(body: tokenBody, partnerToken: partnerToken)
        )
        let tokenPair: TokenPair? = response?.decode()
        return tokenPair
    }

    func getServices() async -> Services? {
        guard let partnerToken = CommonInformation.shared.partnersToken else {
            Logger.print("Partner token is not set")
            return nil
        }
        let response = await networkManager.request(ConstantsApi.processes(partnerToken: partnerToken))
        guard let dictionaries: Services = response?.decode() else { return nil }
        return dictionaries
    }
}
