import SwiftUI
import UIKit

struct ContentView: View {
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil

    @State private var screenshotImage: UIImage? = nil
    @State private var showShareSheet = false
    @State private var navigateToMap = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("🏃 Run App")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Time: \(formattedTime(elapsedTime))")
                    .font(.title)

                // Start/Stop & Navigate Button
                Button(action: {
                    if isRunning {
                        stopRun()
                    } else {
                        startRun()
                        navigateToMap = true
                    }
                }) {
                    Text(isRunning ? "Stop Run" : "Start Run")
                        .padding()
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                // NavigationLink controlled by state
                NavigationLink("", destination: MapView(), isActive: $navigateToMap)
                    .opacity(0)

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
                Button("Share Screenshot") {
                    triggerShare()
                }
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
        }
    }

    func startRun() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }

    func stopRun() {
        isRunning = false
        timer?.invalidate()
    }

    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func saveRunData() {
        let formattedElapsedTime = formattedTime(elapsedTime)
        print("Data saved: \(formattedElapsedTime)")
        UserDefaults.standard.set(formattedElapsedTime, forKey: "savedTime")
    }

    func triggerShare() {
        // Give UI time to finish tap animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shareScreenshot()
        }
    }

    func shareScreenshot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { ctx in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }

        // Present share sheet directly using UIKit
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

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

// Preview
#Preview {
    ContentView()
}
