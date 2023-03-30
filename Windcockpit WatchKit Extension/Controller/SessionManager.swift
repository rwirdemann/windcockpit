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
            start(sessionType: selectedSessionType)
        }
    }
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                reset()
            }
        }
    }
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    @Published var maxSpeed: Double = 0
    @Published var running = false

    var startDate: Date?

    private let locationManager: CLLocationManager

    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func start(sessionType: String) {
        startDate = Date()
        running = true
        locationManager.startUpdatingLocation()
    }
    
    func end() {
        locationManager.stopUpdatingLocation()
        running = false
        showingSummaryView = true
    }
    
    func reset() {
        selectedSessionType = nil
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
    
    func elapsedTime() -> TimeInterval {
        guard let startDate = startDate else { return TimeInterval() }
        return Date().timeIntervalSince(startDate)
    }
}
