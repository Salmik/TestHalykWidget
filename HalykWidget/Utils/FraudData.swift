//
//  FraudData.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 08.10.2024.
//

import UIKit
import MobileSDK
import CoreLocation
import AppTrackingTransparency

class FraudDataConfigurator: NSObject {

    private let locationManager = CLLocationManager()

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        retriveCurrentLocation()
    }

    private func retriveCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()
        if(status == .denied || status == .restricted) {
            return
        }
        if(status == .notDetermined) {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        locationManager.requestLocation()
    }

    static func makeFraudData() -> String { MobileSDKLib.shared.collectInfo() }
}

extension FraudDataConfigurator: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedWhenInUse || status == .authorizedAlways) {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
