//
//  ContentView 2.swift
//  run-tracker
//
//  Created by csuftitan on 3/5/25.
//

let examplePath: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 33.882345662026694, longitude: -117.88513931588159),
            CLLocationCoordinate2D(latitude: 33.88232196202217, longitude: -117.88519641165307),
            CLLocationCoordinate2D(latitude: 33.88227456199336, longitude: -117.88520973399973),
            CLLocationCoordinate2D(latitude: 33.8822145219191, longitude: -117.88516786376734),
            CLLocationCoordinate2D(latitude: 33.88219872189252, longitude: -117.88512028395775),
            CLLocationCoordinate2D(latitude: 33.8822161019216, longitude: -117.88508031691771),
            CLLocationCoordinate2D(latitude: 33.882230321942735, longitude: -117.88505747860911),
            CLLocationCoordinate2D(latitude: 33.88227140199051, longitude: -117.88504034987766)
        ]

import SwiftUI
import MapKit

struct MapView: View
{
    @StateObject private var locationTracker = LocationTracker()
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var polyline: MKPolyline?
    @State private var route: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D()
    ]
    @State private var locationIsRecording: Bool = false
        
    var body: some View
    {
        VStack {
            Map(initialPosition: cameraPosition) {
                UserAnnotation()
                
                MapPolyline(coordinates: route)
                    .stroke(.blue, lineWidth: 4)
            }
            .ignoresSafeArea()
            .tint(.blue)
            .onAppear {
                locationTracker.checkIfLocationServicesIsEnabled()
                //route[0] = locationTracker.region.center
                // THIS^ line is the problem -- gives Apple HQ instead of user location
            }
            .onChange(of: locationTracker.region, initial: false) { oldRegion, newRegion in
                let currentLocation = newRegion.center
                
                if (!locationIsRecording) {
                    route[0] = currentLocation
                    locationIsRecording = true
                } else if (distanceInMeters(from: route.last!, to: currentLocation) >= 1) {
                    route.append(currentLocation)
                }
            }
            .mapControls()
            {
                MapUserLocationButton()
                MapCompass()
                MapPitchToggle()
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

