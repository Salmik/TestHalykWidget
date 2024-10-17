//
//  Services.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 03.10.2024.
//

import Foundation

public struct Services: Decodable {

    public let processes: [Processes]?
}

public struct Processes: Decodable {

    public let name: String?
    public let link: String?
    public let id: Int?
    public let auth: Bool?
}
