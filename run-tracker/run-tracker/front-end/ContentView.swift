//
//  ContentView.swift
//  run-tracker
//
//  Created by csuftitan on 3/1/25.
//


import SwiftUI
import MapKit

struct RunDetailView: View {
    private var dateStr: String
    private var distStr: String
    private var timeStr: String
    private var avgSpeedStr: String
    
    init(run: SavedRunData) {
        dateStr = run.date.formatted(date: .abbreviated, time: .complete)
        distStr = String(run.distance) + " m"
        
        let time = run.time
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        timeStr = String(format: "%02d:%02d", minutes, seconds)
        
        avgSpeedStr = String(run.averageSpeed) + " m/s"
    }
    
    var body: some View {
        VStack {
            Text("\(distStr)\n\(timeStr)\n\(avgSpeedStr)")
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .topLeading
            )
        .padding(.top, 20)
        .background(Color.blue.opacity(0.92))
    }
}

// Run History View
struct RunHistoryView: View {
    var runDataKeys: [String] = []
    
    @State private var showDetail: Bool = false
    @State private var selectedRun: SavedRunData?
    
    var body: some View {
        VStack {
            Text("Previous Runs")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
            
            if (runDataKeys.isEmpty) {
                Text("No previous runs saved yet.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            
            // Placeholder List of Runs (You can use a list to show saved runs from UserDefaults or database)
            ForEach(runDataKeys, id: \.self) { key in
                if let encodedRunData = UserDefaults.standard.object(forKey: key),
                   let runData = try? JSONDecoder().decode(SavedRunData.self, from: encodedRunData as! Data) {
                    
                    Button(action: {
                        showDetail = true
                        selectedRun = runData
                    }) {
                        Text(runData.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(20)
        .shadow(radius: 15)
        .padding()
        
        if showDetail {
            RunDetailView(run: selectedRun!)
                .transition(.opacity)
                .onTapGesture {
                    showDetail = false
                }
                .zIndex(1)
        }
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

struct SavedRunData: Codable {
    var date: Date
    var distance: Double
    var time: TimeInterval
    var averageSpeed: Double
    
    init(date: Date, distance: Double, time: TimeInterval) {
        self.date = date
        self.distance = distance
        self.time = time
        self.averageSpeed = round(distance / time * 100.0) / 100.0
    }
}

// Main Running Tracker View
struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @StateObject private var locationTracker = LocationTracker()

    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var showConfirmation = false // State variable to show confirmation
    @State private var showRuns = false // State variable for showing My Runs view
    @State private var savedRunKeys: [String] = []
    
    @State private var polyline: MKPolyline?
    @State private var route: [CLLocationCoordinate2D] = []
    @State private var distance: Double = 0.0

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Map(initialPosition: cameraPosition) {
                        UserAnnotation()
                        MapPolyline(coordinates: route)
                            .stroke(.blue, lineWidth: 4)
                    }
                    //.ignoresSafeArea(edges: .top)
                    .tint(.blue)
                    .onAppear {
                        locationTracker.checkIfLocationServicesIsEnabled()
                    }
                    .onChange(of: locationTracker.region, initial: false) { oldRegion, newRegion in
                        if (isRunning) {
                            let prevLocation = oldRegion.center
                            let currLocation = newRegion.center
                            
                            let distanceLongDecimal = distanceInMeters(from: prevLocation, to: currLocation)
                            distance = round((distance + distanceLongDecimal) * 100) / 100.0
                            print(distance)
                            
                            if (route.isEmpty || distanceInMeters(from: route.last!, to: currLocation) >= 1) {
                                route.append(currLocation)
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
                    HStack {
                        Text("\(formattedTime(elapsedTime))")
                            .padding()
                            .frame(width: 150)
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        Text("\(String(distance)) m")
                            .padding()
                            .frame(width: 150)
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                        
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
                        /*Button(action: {
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
                        }*/
                    }
                    .padding(.horizontal, 20) // Add horizontal padding to the buttons
                    .padding(.bottom, 30) // Bottom padding to avoid overcrowding
                    
                    Spacer() // Ensures the layout fits well on different screen sizes
                }
                
                // Show "My Runs" View if showRuns is true
                if showRuns {
                    RunHistoryView(runDataKeys: savedRunKeys)
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
        
        // save date, distance, time, and average speed to UserDefault (local storage)
        let runData = SavedRunData(date: Date(), distance: distance, time: elapsedTime)
        let dataDateKey = formattedTime(elapsedTime)
        if let encodedRunData = try? JSONEncoder().encode(runData) {
            UserDefaults.standard.set(encodedRunData, forKey: dataDateKey)
        }
        savedRunKeys.append(dataDateKey)
        
        // get image of entire polyline (screenshot?)...
        // ...save image of entire polyline on map view (still finding best way to save image)
        
        // Reset timer, state, distance, and path (for polyline)
        elapsedTime = 0
        isRunning = false
        timer?.invalidate()
        distance = 0.0
        route.removeAll()
        
        // Show confirmation message
        withAnimation {
            showConfirmation = true
        }
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
    ContentView()
}
