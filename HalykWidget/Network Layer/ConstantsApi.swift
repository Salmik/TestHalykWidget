//
//  ConstantsApi.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 03.10.2024.
//

import Foundation
internal import HalykCore

enum ConstantsApi: EndPointProtocol {

    case processes(partnerToken: String)

    var baseURL: String { "http://halyk-widget-dictionaries-route-halyk-widget-dmz.apps.baas-test-rz.halykbank.nb" }

    var path: String {
        switch self {
        case .processes: return "/dictionaries/api/v1/processes/"
        }
    }

    var timeoutInterval: TimeInterval { 30 }

    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }

    var encoding: EncodingType {
        switch self {
        case .processes: return .json
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .processes: return .get
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .processes(let partnerToken):
            var headers = Constants.headers
            headers["X-Partner-Token"] = "Bearer " + partnerToken
            return headers
        }
    }

    var parameters: Parameters? {
        switch self {
        case .processes: return nil
        }
    }
}
