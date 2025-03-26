//
//  MapDetails.swift
//  run-tracker
//
//  Created by csuftitan on 3/5/25.
//


//
//  MapViewDetails.swift
//  run-tracker
//
//  Created by csuftitan on 2/24/25.
//

import CoreLocation
import MapKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 37.33483, longitude: -122.00892)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
}

final class LocationTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
            center: MapDetails.startingLocation,
            span: MapDetails.defaultSpan
        )
    @Published var locationManager: CLLocationManager?
    
    func getLocation() -> CLLocationCoordinate2D {
        if locationManager?.authorizationStatus == .authorizedAlways, locationManager?.authorizationStatus == .authorizedWhenInUse {
            return region.center
        }
        return MapDetails.startingLocation
    }
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.activityType = .fitness
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.requestWhenInUseAuthorization()
        } else {
            print("Location services are disabled. Prompt the user to enable them in settings.")
        }
    }

    private func checkLocationAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted, likely due to parental controls.")
        case .denied:
            print("You have denied this app location permission. Go into settings to change it.")
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation() // Start getting location updates
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization(manager)
    }

    // When user location updates, zoom in on their position
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MapDetails.defaultSpan // Zoom in closely
            )
        }
    }
}
