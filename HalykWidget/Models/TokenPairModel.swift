//
//  TokenPairModel.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 26.09.2024.
//

import Foundation

public struct TokenPair: Decodable {

    let access_token: String
    let refresh_token: String
}

struct TokenPairModel: Encodable {

    let root_token: String
    let device_id: String
    let expires_at: UInt64
    let salt: String
}

struct TokenPairBody: Encodable {

    let auth_token: String
    let user_name: String
}
