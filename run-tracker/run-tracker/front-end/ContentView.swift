//
//  ContentView.swift
//  run-tracker
//
//  Created by csuftitan on 3/1/25.
//

/*
import SwiftUI

// Main Running Tracker View
struct ContentView: View {
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Text("🏃 Run App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Time: \(formattedTime(elapsedTime))")
                    .font(.title)
                
                // Start/Stop Button
                Button(action: {
                    if isRunning {
                        stopRun()
                    } else {
                        startRun()
                    }
                }) {
                    NavigationLink("Start Run", destination: MapView())
                        .padding()
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .navigationBarBackButtonHidden()
                }
                .padding()
                
                // Save Button
                Button(action: {
                    saveRunData()
                }) {
                    Text("Save Run")
                        .padding()
                    
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                // Share Screenshot Button
                Button(action: {
                    // Placeholder action for sharing a screenshot (not implemented)
                    shareScreenshot()
                }) {
                    Text("Share Screenshot")
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    func startRun() {
        isRunning = true
        
        // Start the timer when the user clicks Start
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    func stopRun() {
        isRunning = false
        timer?.invalidate() // Stop the timer
    }
    
    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func saveRunData() {        // WE'RE NOT SAVING DATA (yet?)
        // Placeholder function for saving run data (not implemented)
        let formattedElapsedTime = formattedTime(elapsedTime)
        print("Save button pressed saving run data please wait")
        print("Data has been successfully saved in history!")
        UserDefaults.standard.set(formattedElapsedTime, forKey: "savedTime")
    }

    func shareScreenshot() {
        // Placeholder function for sharing a screenshot (not implemented)
        // Roberto Manra’s Portion since he is handling screenshots
    }
}*/


// NEW UI:

import SwiftUI
import MapKit

// Run History View
struct RunHistoryView: View {
    var body: some View {
        VStack {
            Text("Previous Runs")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
            // Placeholder for previous runs, this can be dynamically populated
            Text("No previous runs saved yet.")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            // Placeholder List of Runs (You can use a list to show saved runs from UserDefaults or database)
            List {
                ForEach(0..<5, id: \.self) { _ in
                    Text("Run #1")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)
            .shadow(radius: 10)
            .padding(.top, 20)
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(20)
        .shadow(radius: 15)
        .padding()
    }
}

struct ConfirmationView: View {
    var body: some View {
        VStack {
            Text("Your Run was Saved")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            Text("Click My Runs to view it")
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(width: 300, height: 120)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        .transition(.opacity)
    }
}

// Main Running Tracker View
struct OLDContentView: View {
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @StateObject private var locationTracker = LocationTracker()

    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var showConfirmation = false // State variable to show confirmation
    @State private var showRuns = false // State variable for showing My Runs view
    
    @State private var polyline: MKPolyline?
    @State private var route: [CLLocationCoordinate2D] = []
    @State private var locationIsRecording: Bool = false
    @State private var distance: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Map(initialPosition: cameraPosition) {
                        UserAnnotation()
                        MapPolyline(coordinates: route)
                            .stroke(.blue, lineWidth: 4)
                    }
                    .ignoresSafeArea(edges: .top)
                    .tint(.blue)
                    .onAppear {
                        locationTracker.checkIfLocationServicesIsEnabled()
                    }
                    .onChange(of: locationTracker.region, initial: false) { oldRegion, newRegion in
                        if (isRunning) {
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
                    }
                    .padding(.top, 20)
                    .frame(height: 400)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .mapControls()
                    {
                        MapUserLocationButton()
                        MapScaleView()
                    }
                    // Timer Section
                    Text("Time: \(formattedTime(elapsedTime))")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .shadow(radius: 5)
                    
                    // buttons section
                    VStack(spacing: 16) {
                        // My Runs Button
                        Button(action: {
                            showRuns = true // Show "My Runs" view
                        }) {
                            Text("My Runs")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .top, endPoint: .bottom))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                         
                        // Start/Stop Button
                        Button(action: {
                            if isRunning {
                                stopRun()
                            } else {
                                startRun()
                            }
                        }) {
                            Text(isRunning ? "Stop Run" : "Start Run")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isRunning ? Color.red : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                         
                        // Save Run Button
                        Button(action: {
                            saveRunData()
                        }) {
                            Text("Save Run")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                        .disabled(elapsedTime == 0) // Disable Save button if no time elapsed
                        
                        // Share Screenshot Button
                        Button(action: {
                            shareScreenshot()
                        }) {
                            Text("Share Screenshot")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal, 20) // Add horizontal padding to the buttons
                    .padding(.bottom, 30) // Bottom padding to avoid overcrowding
                    
                    Spacer() // Ensures the layout fits well on different screen sizes
                }
                
                // Show "My Runs" View if showRuns is true
                if showRuns {
                    RunHistoryView()
                        .transition(.opacity)
                        .onTapGesture {
                            showRuns = false // Hide the My Runs view when tapped
                        }
                        .zIndex(1) // Ensure it is on top of other views
                }
                
                // Confirmation Overlay
                if showConfirmation {
                    ConfirmationView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showConfirmation = false
                                }
                            }
                        }
                }
            }
            .background(Color.black.opacity(0.8)) // Add a darker background for contrast
            //.ignoresSafeArea() // Ensure the background covers the whole screen
        }
    }
    
    private func distanceInMeters(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        return endLocation.distance(from: startLocation)
    }
    
    private func startRun() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    private func stopRun() {
        isRunning = false
        timer?.invalidate()
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func saveRunData() {
        let formattedElapsedTime = formattedTime(elapsedTime)
        print("Run data saved: \(formattedElapsedTime)")
        UserDefaults.standard.set(formattedElapsedTime, forKey: "savedTime")
        
        // Reset timer and state
        elapsedTime = 0
        isRunning = false
        timer?.invalidate()
        
        // Show confirmation message
        withAnimation {
            showConfirmation = true
        }
    }
    
    private func shareScreenshot() {
        print("Share screenshot tapped")
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

// Add function for Map View
// Preview
#Preview {
    OLDContentView()
}
