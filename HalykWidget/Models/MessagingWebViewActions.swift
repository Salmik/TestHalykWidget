//
//  MessagingWebViewActions.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 05.09.2024.
//

import Foundation
internal import HalykCore

enum MessagingWebViewActions: String, CaseIterable {

    case liveness
    case close

    init?(rawValue: String) {
        if rawValue.range(of: "liveness") != nil {
            self = .liveness
        } else {
            guard let type = Self.allCases.first(where: { $0.rawValue == rawValue }) else { return nil }
            self = type
        }
    }
}
