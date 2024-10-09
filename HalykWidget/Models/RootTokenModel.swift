//
//  RootTokenModel.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 26.09.2024.
//

import Foundation

struct RootTokenModel: Codable {

    struct RootTokenBody: Codable {
        let user_name: String
        let password: String
    }

    let partnerToken: String
    let fingerPrint: String
    let body: RootTokenBody
}
