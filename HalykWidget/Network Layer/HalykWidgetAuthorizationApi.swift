//
//  HalykWidgetAuthorizationApi.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 26.09.2024.
//

import Foundation
internal import HalykCore

enum HalykWidgetAuthorizationApi: EndPointProtocol {

    case rootToken(info: RootTokenModel)
    case publicKey(partnerToken: String)
    case serverTime
    case partnerToken(login: String, password: String)
    case tokenPair(body: TokenPairBody, partnerToken: String)
    case sendLivenessVideo(accessToken: String)

    var baseURL: String { Constants.baseUrl }

    var path: String {
        switch self {
        case .serverTime: return "/auth/api/v1/server/time"
        case .partnerToken: return "/auth/partner/api/v1/login"
        case .rootToken: return "/auth/api/v1/token/root"
        case .publicKey: return "/auth/api/v1/publickey"
        case .tokenPair: return "/auth/api/v1/token/get"
        case .sendLivenessVideo: return ""
        }
    }

    var timeoutInterval: TimeInterval {
        switch self {
        case .serverTime: return 30
        default: return 60
        }
    }

    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .serverTime: return .reloadIgnoringLocalAndRemoteCacheData
        default: return .useProtocolCachePolicy
        }
    }

    var encoding: EncodingType {
        switch self {
        case .serverTime: return .json
        case .partnerToken: return .json
        case .rootToken: return .json
        case .publicKey: return .json
        case .tokenPair: return .json
        case .sendLivenessVideo: return .none
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .serverTime: return .get
        case .publicKey: return .get
        case .partnerToken: return .post
        case .rootToken: return .post
        case .tokenPair: return .post
        case .sendLivenessVideo: return .post
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .publicKey(let token):
            var headers = Constants.headers
            headers["X-Partner-Token"] = token
            return headers
        case .rootToken(let info):
            var headers = Constants.headers
            headers["X-Partner-Token"] = info.partnerToken
            headers["X-Device-ID"] = info.fingerPrint
            return headers
        case .tokenPair(_, let partnerToken):
            var headers = Constants.headers
            headers["X-Partner-Token"] = partnerToken
            return headers
        case .sendLivenessVideo(let token):
            var headers = Constants.headers
            headers["X-Forensic-Access-Token"] = token
            return headers
        default:
            return Constants.headers
        }
    }

    var parameters: Parameters? {
        switch self {
        case .serverTime: return nil
        case .partnerToken(let login, let password): return ["password": password, "user_name": login]
        case .rootToken(let info): return encode(info.body)
        case .tokenPair(let body, _): return encode(body)
        case .publicKey: return nil
        case .sendLivenessVideo: return nil
        }
    }
}
