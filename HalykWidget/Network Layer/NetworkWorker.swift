//
//  AuthorizationNetworkWorker.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 26.09.2024.
//

import Foundation
internal import HalykCore

class NetworkWorker {

    private lazy var networkManager: NetworkManager = {
        let networkManager = NetworkManager()
        networkManager.isNeedToLogRequests = true
        networkManager.isSSLPinningEnabled = false
        let bundle = Bundle(identifier: "kz.halyk.partner") ?? .main
        networkManager.certDataItems = bundle.SSLCertificates
        return networkManager
    }()
    private let keychainManager = KeychainService()
    private let rsaWorker = RSAWorker()
    private let jsonWorker = JSONWorker()

    func getPartnerToken(login: String, password: String) async -> String? {
        let partnerToken = await networkManager.request(
            HalykWidgetAuthorizationApi.partnerToken(login: login, password: password)
        )?.json?["token"] as? String
        CommonInformation.shared.partnersToken = partnerToken

        return partnerToken
    }

    func getServerTime() async -> String? {
        let serverTime = await networkManager.request(
            HalykWidgetAuthorizationApi.serverTime
        )?.json?["server_time"] as? String
        CommonInformation.shared.serverTime = serverTime

        return serverTime
    }

    func getPublicKey() async -> String? {
        guard let partnerToken = CommonInformation.shared.partnersToken else {
            Logger.print("Partner token is not set")
            return nil
        }
        let publicKey = await networkManager.request(
            HalykWidgetAuthorizationApi.publicKey(partnerToken: partnerToken)
        )?.json?["key"] as? String
        CommonInformation.shared.publicKey = publicKey

        return publicKey
    }

    func getRootToken() async -> String? {
        if let data = try? keychainManager.load(key: KeychainKeys.rootToken) {
            let rootToken = String(data: data, encoding: .utf8)
            CommonInformation.shared.rootToken = rootToken
            return rootToken
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
            CommonInformation.shared.rootToken = rootToken

            return rootToken
        }
    }

    @discardableResult
    func getTokenPair() async -> TokenPair? {
        let fetchedServerTime: String
        let fetchedPublicKey: String
        let fetchedRootToken: String
        let fetchedPartnersToken: String

        if let partnersToken = CommonInformation.shared.partnersToken {
            fetchedPartnersToken = partnersToken
        } else {
            fetchedPartnersToken = await getPartnerToken(
                login: CommonInformation.shared.partnerUserName,
                password: CommonInformation.shared.partnerPassword
            ) ?? ""
        }

        if let serverTime = CommonInformation.shared.serverTime {
            fetchedServerTime = serverTime
        } else {
            fetchedServerTime = await getServerTime() ?? ""
        }

        if let publicKey = CommonInformation.shared.publicKey {
            fetchedPublicKey = publicKey
        } else {
            fetchedPublicKey = await getPublicKey() ?? ""
        }

        if let rootToken = CommonInformation.shared.rootToken {
            fetchedRootToken = rootToken
        } else {
            fetchedRootToken = await getRootToken() ?? ""
        }

        let tokepairBody = TokenPairModel(
            root_token: fetchedRootToken,
            device_id: DeviceInfoCollector.deviceInfoHash(),
            expires_at: TimeStampCalculator.callculate(from: fetchedServerTime),
            salt: "Salt"
        )
        let json = jsonWorker.makeJSon(from: tokepairBody)
        let encodedJson = rsaWorker.encrypt(json, publicKey: fetchedPublicKey) ?? ""
        let tokenBody = TokenPairBody(auth_token: encodedJson, user_name: "User name")
        let response = await networkManager.request(
            HalykWidgetAuthorizationApi.tokenPair(body: tokenBody, partnerToken: fetchedPartnersToken)
        )
        let tokenPair: TokenPair? = response?.decode()
        CommonInformation.shared.tokenPair = tokenPair

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
