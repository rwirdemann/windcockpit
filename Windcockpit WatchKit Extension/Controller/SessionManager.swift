//
//  SessionManager.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 30.03.23.
//

import Foundation
import CoreLocation

class SessionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var selectedSessionType: String? {
        didSet {
            guard let selectedSessionType = selectedSessionType else { return }
            startSession(sessionType: selectedSessionType)
        }
    }
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetSession()
            }
        }
    }

    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    @Published var maxSpeed: Double = 0
    @Published var running = false

    private let locationManager: CLLocationManager

    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startSession(sessionType: String) {
        locationManager.startUpdatingLocation()
    }
    
    func endSession() {
        locationManager.stopUpdatingLocation()
    }
    
    func resetSession() {
        
    }
    
    func requestLocationManagerPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        fetchCountryAndCity(for: locations.first)

        let currentSpeed = self.lastSeenLocation?.speed ?? 0
        if currentSpeed > maxSpeed {
            maxSpeed = currentSpeed
        }
    }

    func fetchCountryAndCity(for location: CLLocation?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
        }
    }
    
    func currentSpeed() -> CLLocationSpeed {
        let speed = lastSeenLocation?.speed ?? 0
        if speed < 0 {
            return 0
        }
        return speed
    }
}
