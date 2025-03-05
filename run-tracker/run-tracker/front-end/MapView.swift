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
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View
    {
        VStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation:true)
                .ignoresSafeArea()
                .accentColor(Color(.systemPink))
                .onAppear {
                    viewModel.checkIfLocationServicesIsEnabled()
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
}
    
#Preview
{
    MapView()
}
