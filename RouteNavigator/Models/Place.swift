//
//  Place.swift
//  NearbyPlacesApp
//
//  Created by Noman belim on 02/01/26.
//
//
//  Place.swift
//  NearbyPlacesApp
//
//  Created by Noman belim on 02/01/26.
//
import CoreLocation

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
}
