import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "shoe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Run-tracker")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
