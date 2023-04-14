//
//  SessionManager.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 30.03.23.
//

import Foundation
import CoreLocation
import HealthKit
import WatchKit

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
                if let currentSession = currentSession {
                    currentSession.distance = workout?.totalDistance?.doubleValue(for: .meter()) ?? 0
                    currentSession.duration = builder?.elapsedTime ?? 0
                    try! PersistenceController.shared.container.viewContext.save()
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

    // Collect session data for sync with iPhone
    private var currentSession: SessionEntity?

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
        currentSession = SessionEntity(context: PersistenceController.shared.container.viewContext)
        currentSession?.name = sessionType
        currentSession?.date = startDate

        locationManager.startUpdatingLocation()
        
        workoutSession?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
        }
    }
    
    func end() {
        locationManager.stopUpdatingLocation()
        workoutSession?.end()

        // Use current date as location fallback
        if currentSession?.location == nil {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "de")
            formatter.dateFormat = "d. MMMM y, HH:mm"
            currentSession?.location = "New: \(formatter.string(from: Date()))"
        }
                
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
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            
            locationList.append(newLocation)
        }
        fetchCity(location: locationList.last)
    }
    
    func fetchCity(location: CLLocation?) {
        if currentSession?.location != nil {
            return
        }
        
        guard let location = location else { return }
        location.placemark { placemark, error in
            guard let placemark = placemark else {
                print("Error:", error ?? "nil")
                return
            }
            self.currentSession?.location = placemark.locality!
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

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) {
            completion($0?.first, $1)
        }
    }
}
