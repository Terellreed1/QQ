import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var currentBuilding: Building?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.requestLocation()
    }
    
    private func findNearbyBuilding(for location: CLLocation) {
        // In a real app, this would query a database of buildings
        // For now, we'll use sample data
        let sampleBuildings = [
            Building(id: "1", name: "Smith Hall", coordinate: .init(latitude: 40.7580, longitude: -73.9855), activeUsers: 24, whisperCount: 156),
            Building(id: "2", name: "Johnson Library", coordinate: .init(latitude: 40.7590, longitude: -73.9845), activeUsers: 18, whisperCount: 89),
            Building(id: "3", name: "Davis Center", coordinate: .init(latitude: 40.7570, longitude: -73.9865), activeUsers: 31, whisperCount: 203)
        ]
        
        let nearbyBuilding = sampleBuildings.min { building1, building2 in
            let distance1 = location.distance(from: CLLocation(latitude: building1.coordinate.latitude, longitude: building1.coordinate.longitude))
            let distance2 = location.distance(from: CLLocation(latitude: building2.coordinate.latitude, longitude: building2.coordinate.longitude))
            return distance1 < distance2
        }
        
        // Only consider a building "current" if within 100 meters
        if let building = nearbyBuilding {
            let distance = location.distance(from: CLLocation(latitude: building.coordinate.latitude, longitude: building.coordinate.longitude))
            if distance <= 100 {
                DispatchQueue.main.async {
                    self.currentBuilding = building
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
        }
        findNearbyBuilding(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
}