import SwiftUI
import MapKit

struct ContentView: View
{
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View
    {
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
    }
}
    
#Preview
{
    ContentView()
}
