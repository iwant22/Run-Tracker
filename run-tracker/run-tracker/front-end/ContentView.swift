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
    private var distInMilesStr: String
    private var timeStr: String
    private var route: [CLLocationCoordinate2D]
    private var avgSpeedFPSStr: String
    private var avgSpeedMPHStr: String
    @State private var showAvgSpeedInMPH: Bool = false
    @Binding var showDetailView: Bool
    
    init(run: SavedRunData, showDetailView: Binding<Bool>) {
        self.dateStr = run.date.formatted(date: .abbreviated, time: .complete)
        self.distInMilesStr = (String(round(run.distanceInFeet * 0.0189394) / 100.0) + " mi")
        
        let time = run.time
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        self.timeStr = String(format: "%02d:%02d", minutes, seconds)
        
        self.route = run.codableRoute.map { codableCoord in
            CLLocationCoordinate2D(latitude: codableCoord.latitude, longitude: codableCoord.longitude)
        }
        
        self.avgSpeedFPSStr = String(run.averageSpeedFPS) + " fps"
        self.avgSpeedMPHStr = String(round(run.averageSpeedFPS * 68.1818) / 100.0) + " mph"
        
        self._showDetailView = showDetailView
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showDetailView = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
                .padding(.top)
                ZStack {
                    Map() {
                        MapPolyline(coordinates: route)
                            .stroke(.blue, lineWidth: 4)
                    }
                    .tint(.blue)
                }
                .frame(width: 380, height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 10)
                HStack {
                    Text(timeStr)
                        .padding()
                        .frame(width: 175)
                        .font(.title)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    Text(distInMilesStr)
                        .padding()
                        .frame(width: 175)
                        .font(.title)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                Button(action: {
                    showAvgSpeedInMPH = !showAvgSpeedInMPH
                }) {
                    Text("Avg Speed: " + (showAvgSpeedInMPH ? avgSpeedMPHStr : avgSpeedFPSStr))
                        .padding()
                        .frame(width: 358)
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .top
            )
        .background(Color.blue.opacity(0.97))
    }
}

// Run History View
struct RunHistoryView: View {
    @State var runDataKeys: [String] = []
    @Binding var showRuns: Bool

    @State private var selectedRun: SavedRunData?
    @State private var showDetailView: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showRuns = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topTrailing)
            
            ScrollView {
                Text("Previous Runs")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                if runDataKeys.isEmpty {
                    Text("No previous runs saved yet.")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                }
                
                // Updated ForEach
                ForEach(runDataKeys, id: \.self) { key in
                    if let encodedRunData = UserDefaults.standard.object(forKey: key),
                       let runData = try? JSONDecoder().decode(SavedRunData.self, from: encodedRunData as! Data) {
                        
                        HStack {
                            // Button to show run details
                            Button(action: {
                                showDetailView = true
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

                            Spacer()

                            // Trash button to delete
                            Button(action: {
                                withAnimation {
                                    deleteRun(withKey: key)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: 400, maxHeight: 400)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .top,
                           endPoint: .bottom)
        )
        .cornerRadius(20)
        .shadow(radius: 15)
        
        // Show Detail View if selected
        if showDetailView {
            RunDetailView(run: selectedRun!, showDetailView: $showDetailView)
                .transition(.opacity)
                .zIndex(1)
        }
    }
    
    // 🔵 Here's the deleteRun function (OUTSIDE body)
    private func deleteRun(withKey key: String) {
        // Remove data from UserDefaults
        UserDefaults.standard.removeObject(forKey: key)
        
        // Remove the key from the runDataKeys array
        if let index = runDataKeys.firstIndex(of: key) {
            runDataKeys.remove(at: index)
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
                .foregroundColor(.black)
        }
        .frame(width: 300, height: 120)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        .transition(.opacity)
    }
}

struct CodableCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(clCoordinate: CLLocationCoordinate2D) {
        self.latitude = clCoordinate.latitude
        self.longitude = clCoordinate.longitude
    }
    
    var toCLLocatoinCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct SavedRunData: Codable {
    var date: Date
    var distanceInFeet: Double
    var time: TimeInterval
    var codableRoute: [CodableCoordinate]
    var averageSpeedFPS: Double
    
    init(date: Date, distanceInFeet: Double, time: TimeInterval, clCoordsArr: [CLLocationCoordinate2D]) {
        self.date = date
        self.distanceInFeet = distanceInFeet
        self.time = time
        self.codableRoute = clCoordsArr.map { clCoord in
            CodableCoordinate(clCoordinate: clCoord)
        }
        self.averageSpeedFPS = round(distanceInFeet / time * 100.0) / 100.0      // avg speed in feet/sec rounded to nearest 100th
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
                        Text(formattedTime(elapsedTime))
                            .padding()
                            .frame(width: 175)
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        Text(String(distance) + " ft")
                            .padding()
                            .frame(width: 175)
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
                        Button(action: {
                            triggerShare()
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
                    RunHistoryView(runDataKeys: savedRunKeys, showRuns: $showRuns)
                        .transition(.opacity)
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
        return endLocation.distance(from: startLocation) * 3.28084      // gets distance and converts from meters to feet
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
        // save date, distance, time, and average speed to UserDefault (local storage)
        let currDate = Date()
        let dataDateKey = String(currDate.timeIntervalSince1970)
        let runData = SavedRunData(date: currDate, distanceInFeet: distance, time: elapsedTime, clCoordsArr: route)
        if let encodedRunData = try? JSONEncoder().encode(runData) {
            UserDefaults.standard.set(encodedRunData, forKey: dataDateKey)
        }
        savedRunKeys.append(dataDateKey)
        print("Run Data Saved with key: \(dataDateKey)")
        
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
    
    private func triggerShare() {
        // Give UI time to finish tap animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shareScreenshot()
        }
    }

    private func shareScreenshot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        let fullBounds = window.bounds
        let scale = window.screen.scale

        // 🛠 Instead of rendering full window, define a smaller rect
        let desiredHeightPoints: CGFloat = 575  // You can fine-tune this later
        let smallRect = CGRect(x: 0, y: 0, width: fullBounds.width, height: desiredHeightPoints)

        let renderer = UIGraphicsImageRenderer(bounds: smallRect)
        let image = renderer.image { ctx in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }

        // No need to crop afterward!
        let finalImage = UIImage(cgImage: image.cgImage!, scale: scale, orientation: .up)

        let activityVC = UIActivityViewController(activityItems: [finalImage], applicationActivities: nil)

        if let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }




}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
