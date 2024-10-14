//
//  Scripts.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 10.10.2024.
//

import UIKit.UIApplication

struct Scripts {

    static func getInitialPayloadScript() -> String {
        let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        let fraudData = FraudDataConfigurator.makeFraudData()
        let page = "HomePage"

        let safePartnerToken = CommonInformation.shared.partnersToken?.replacingOccurrences(of: "'", with: "\\'") ?? ""
        let safeFraudData = fraudData
        let safePage = page.replacingOccurrences(of: "'", with: "\\'")

        let script = """
        window.HalykWidget = {
            partnerToken: '\(safePartnerToken)',
            fraudData: '\(safeFraudData)',
            top: \(safeAreaTop),
            bottom: \(safeAreaBottom),
            page: '\(safePage)'
        };
        """

        return script
    }

    static func livenessOk() -> String {
        let script = """
            window.dispatchEvent(new CustomEvent('livenessDone', {
              detail: {
                status: 'ok'
              }
            }));
        """
        return script
    }
}
