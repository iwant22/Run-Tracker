import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color.blue.ignoresSafeArea() // Background color

                VStack {
                    Image("run tracker logo") // Use an SF Symbol
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .foregroundColor(.white) // White color for SF Symbol

                    Text("The Running App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .onAppear {
                // Force the SF Symbol to load before showing the screen
                _ = Image(systemName: "figure.run")

                // Keep splash screen visible for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
