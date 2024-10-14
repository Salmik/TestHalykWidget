//
//  LivenessInfoData.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 10.10.2024.
//

import Foundation

struct LivenessInfoData: Decodable {

    struct LivenessInfo: Decodable {
        let folderID: String?
        let hbAuth: String?
        let livenessAuth: String?
        let livenessType: String?
        let url: String?
    }

    let liveness: LivenessInfo?
}
