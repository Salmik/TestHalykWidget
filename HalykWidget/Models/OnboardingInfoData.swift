//
//  OnboardingInfoData.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 17.10.2024.
//

import Foundation

struct OnboardingInfoData: Decodable {

    struct OnboardingSuccessData: Decodable {
        let password: String?
        let user_name: String?
    }

    let onboardingSuccess: OnboardingSuccessData?
}
