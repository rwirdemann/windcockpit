//
//  SessionManager.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 30.03.23.
//

import Foundation
import CoreLocation
import HealthKit

class SessionTracker: NSObject, ObservableObject, CLLocationManagerDelegate {

    var selectedSessionType: String? {
        didSet {
            guard let selectedSessionType = selectedSessionType else { return }
            start(sessionType: selectedSessionType)
        }
    }
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                if var currentSession = currentSession {
                    currentSession.distance = workout?.totalDistance?.doubleValue(for: .meter()) ?? 0
                    currentSession.duration = builder?.elapsedTime ?? 0
                    sessionList.append(currentSession)
                }
                reset()
            }
        }
    }
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var maxSpeed: Double = 0
    @Published var running = false
    @Published var hkDistance: Double = 0
    @Published var workout: HKWorkout?

    // Collect sessions for sync with iPhone
    private var currentSession: Session?
    @Published var sessionList: [Session] = []

    var distance = Measurement(value: 0, unit: UnitLength.meters)

    private let locationManager: CLLocationManager
    private var locationList: [CLLocation] = []
    var currentPlacemark: CLPlacemark?

    let healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func start(sessionType: String) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .cycling
        configuration.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = workoutSession?.associatedWorkoutBuilder()
        } catch {
            return
        }
        workoutSession?.delegate = self
        builder?.delegate = self

        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)

        let startDate = Date()
        currentSession = Session(
            id: 0,
            location: "",
            name: sessionType,
            date: startDate,
            distance: 0,
            maxspeed: 0,
            duration: 0,
            locationId: 0
        )

        locationManager.startUpdatingLocation()
        
        workoutSession?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
        }
    }
    
    func end() {
        locationManager.stopUpdatingLocation()
        workoutSession?.end()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de")
        formatter.dateFormat = "d. MMMM y, HH:mm"
        currentSession?.location = currentPlacemark?.locality ?? "New: \(formatter.string(from: Date()))"
        showingSummaryView = true
    }
    
    func reset() {
        selectedSessionType = nil
        currentSession = nil
        builder = nil
        workout = nil
        workoutSession =  nil
        distance = Measurement(value: 0, unit: UnitLength.meters)
        hkDistance = 0
        locationList.removeAll()
    }
    
    func requestLocationManagerPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        fetchCountryAndCity(for: locations.first)
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
    
    func requestAuthorization() {
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
        }
    }
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.hkDistance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }
    
    func sync() {
        for s in sessionList {
            WatchConnectivityManager.shared.send(s)
        }
    }
}

extension SessionTracker: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }
        
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }
}

extension SessionTracker: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}
