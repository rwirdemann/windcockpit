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
    @Published var currentPlacemark: CLPlacemark?
    @Published var maxSpeed: Double = 0
    @Published var running = false

    var startDate: Date?
    var distance = Measurement(value: 0, unit: UnitLength.meters)

    private let locationManager: CLLocationManager
    private var locationList: [CLLocation] = []

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
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
    }
    
    func requestLocationManagerPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            
            locationList.append(newLocation)
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
        if let lastLocation = locationList.last {
            return max(0, lastLocation.speed)
        }
        return 0
    }
    
    func elapsedTime() -> TimeInterval {
        guard let startDate = startDate else { return TimeInterval() }
        return Date().timeIntervalSince(startDate)
    }
}
