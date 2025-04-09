//
//  LocationTracker.swift
//  run-tracker
//
//  Created by Quentin Rivest on 2/25/25.
//

import Combine
import CoreLocation

class LocationTracker: NSObject, CLLocationManagerDelegate, ObservableObject {
    var coordinatesPublisher = PassthroughSubject<CLLocationCoordinate2D, Error>()
    
    private override init() {
        super.init()
    }
    
    static let shared = LocationTracker()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        coordinatesPublisher.send(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordinatesPublisher.send(completion: .failure(error))
    }
    
    
}
