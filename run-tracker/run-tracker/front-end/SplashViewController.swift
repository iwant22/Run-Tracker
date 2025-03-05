import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Text(" RunApp")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isActive = true
                }
            }
        }
    }
}
