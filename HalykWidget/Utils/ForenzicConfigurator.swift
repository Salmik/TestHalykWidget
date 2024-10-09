//
//  ForenzicConfigurator.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 19.09.2024.
//

//import Foundation
//import UIKit.UIColor
//import OZLivenessSDK
//
//class ForenzicConfigurator {
//
//    static func configure() {
//        let bundle = Bundle(for: HalykWidgetController.self)
//        print("ForenzicConfigurator: \(bundle.bundleIdentifier ?? "")")
//        guard let path = bundle.path(forResource: "forensics", ofType: "license") else {
//            print("Not found Forenzics license file")
//            return
//        }
//
//        do {
//            try OZSDK.set(licenseBundle: bundle)
//            print("License was set")
//        } catch let error {
//            print("Not possible to set Forenzics license")
//            dump(error)
//        }
//
//        OZSDK(licenseSources: [.licenseFilePath(path)]) { (result, error) in
//            if let error {
//                print("MY ERROR!")
//                print(error)
//            }
//            if result != nil {
//                print("Have results!")
//            }
//        }
//
//        let hintAnimationCustomization = HintAnimationCustomization(
//            hideAnimation: true,
//            animationIconSize: 0,
//            hintGradientColor: .clear
//        )
//        let centerHintCustomization = CenterHintCustomization(verticalPosition: 10, hideTextBackground: true)
//        let faceFrameCustomization = FaceFrameCustomization(
//            strokeWidth: 4,
//            strokeFaceAlignedColor: UIColor.systemGreen,
//            strokeFaceNotAlignedColor: UIColor.red,
//            geometryType: .oval,
//            strokePadding: 0
//        )
//        let backgroundCustomization = BackgroundCustomization(backgroundColor: .darkGray.withAlphaComponent(0.85))
//
//        OZSDK.customization.faceFrameCustomization = faceFrameCustomization
//        OZSDK.customization.hintAnimationCustomization = hintAnimationCustomization
//        OZSDK.customization.backgroundCustomization = backgroundCustomization
//        OZSDK.customization.centerHintCustomization = centerHintCustomization
//
//        OZSDK.attemptSettings = OZAttemptSettings(singleCount: 2, commonCount: 3)
//        OZSDK.localizationCode = .ru
//    }
//}
