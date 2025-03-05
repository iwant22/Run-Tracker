//
//  ContentView.swift
//  run-tracker
//
//  Created by csuftitan on 3/1/25.
//


import SwiftUI
// Quentin and Roberto’s portion

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
    // Quentin’s Portion for Motion Tracking (Part of backend)

    func saveRunData() {        // WE'RE NOT SAVING DATA (yet?)
        // Placeholder function for saving run data (not implemented)
        let formattedElapsedTime = formattedTime(elapsedTime)
        print("Save button pressed saving run data please wait")
        print("Data has been successfully saved in history!")
        UserDefaults.standard.set(formattedElapsedTime, forKey: "savedTime")
        // Quentin’s portion for backend
    }

    func shareScreenshot() {
        // Placeholder function for sharing a screenshot (not implemented)
        // Roberto Manra’s Portion since he is handling screenshots
    }
}

// Add function for Map View
// Preview
#Preview {
    ContentView()
}
