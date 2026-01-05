//
//  LocationManager.swift
//  NearbyPlacesApp
//
//  Created by Noman belim on 02/01/26.
//

import CoreLocation
import Foundation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var locationName: String = "Fetching location..."
    @Published var permissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoadingLocation: Bool = true
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()
    }
    
    // MARK: - Permission Handling
    
    private func checkLocationAuthorization() {
        permissionStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            locationName = "Location access denied"
            isLoadingLocation = false
            
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            
        @unknown default:
            break
        }
    }
    
    func refreshLocation() {
        isLoadingLocation = true
        locationName = "Updating location..."
        manager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        permissionStatus = manager.authorizationStatus
        checkLocationAuthorization()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let loc = locations.last else { return }
        
        location = loc
        isLoadingLocation = false
        reverseGeocode(location: loc)
        
        // Stop continuous updates to save battery
        manager.stopUpdatingLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("❌ Location error:", error.localizedDescription)
        locationName = "Unable to get location"
        isLoadingLocation = false
    }
    
    // MARK: - Reverse Geocoding
    
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            
            if let error {
                print("❌ Geocoding error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.locationName = "Location unavailable"
                }
                return
            }
            
            guard let placemark = placemarks?.first else {
                DispatchQueue.main.async {
                    self.locationName = "Unknown location"
                }
                return
            }
            
            // Build location name
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            
            DispatchQueue.main.async {
                self.locationName = [city, state, country]
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
                
                if self.locationName.isEmpty {
                    self.locationName = "Current location"
                }
            }
        }
    }
}
