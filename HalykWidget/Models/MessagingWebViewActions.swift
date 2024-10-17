//
//  MessagingWebViewActions.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 05.09.2024.
//

import Foundation

enum MessagingWebViewActions: String, CaseIterable {

    case liveness
    case onboardingSuccess
    case close

    init?(rawValue: String) {
        guard let json = MessagingWebViewActions.jsonStringToDictionary(rawValue),
              let key = json.keys.first else {
            return nil
        }

        switch key {
         case "liveness":
             if json["liveness"] is [String: Any] {
                 self = .liveness
             } else {
                 return nil
             }
         case "onboardingSuccess":
             if json["onboardingSuccess"] is [String: Any] {
                 self = .onboardingSuccess
             } else {
                 return nil
             }
         case "close":
             if let value = json["close"] as? String, value == "close" {
                 self = .close
             } else {
                 return nil
             }
         default:
             return nil
         }
    }

    private static func jsonStringToDictionary(_ jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let dictionary = jsonObject as? [String: Any] else { return nil }
            return dictionary
        } catch {
            print("Error converting JSON string to dictionary: \(error)")
            return nil
        }
    }
}
