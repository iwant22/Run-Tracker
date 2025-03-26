//
//  ContentView 2.swift
//  run-tracker
//
//  Created by csuftitan on 3/5/25.
//

import SwiftUI
import MapKit

struct MapView: View
{
    @StateObject private var locationTracker = LocationTracker()
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var polyline: MKPolyline?
    @State private var route: [CLLocationCoordinate2D] = []
    @State private var locationIsRecording: Bool = false
    @State var distance: Double = 0
        
    var body: some View
    {
        VStack {
            Map(initialPosition: cameraPosition) {
                UserAnnotation()
                
                MapPolyline(coordinates: route)
                    .stroke(.blue, lineWidth: 4)
            }
            .tint(.blue)
            .onAppear {
                locationTracker.checkIfLocationServicesIsEnabled()
            }
            .onChange(of: locationTracker.region, initial: false) { oldRegion, newRegion in
                let prevLocation = oldRegion.center
                let currLocation = newRegion.center
                
                if (locationIsRecording) {
                    distance += distanceInMeters(from: prevLocation, to: currLocation)
                    print(distance)
                }
                
                if (!locationIsRecording ||
                    distanceInMeters(from: route.last!, to: currLocation) >= 1) {
                    route.append(currLocation)
                    
                    if !locationIsRecording {locationIsRecording = true}
                }
            }
            .mapControls()
            {
                MapUserLocationButton()
                MapScaleView()
            }
            
            NavigationLink("Stop Run", destination: ContentView())
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            
        }
    }
    
    private func distanceInMeters(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        return endLocation.distance(from: startLocation)
    }
    
    // comment this accessor function for distance member var if needed:
    /*func getDistance() -> Double {
        return distance
    }*/
}

extension MKCoordinateRegion: @retroactive Equatable {
    public static func ==(lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
               lhs.center.longitude == rhs.center.longitude &&
               lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
               lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}
    
#Preview
{
    MapView()
}

