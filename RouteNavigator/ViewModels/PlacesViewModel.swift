//
//  PlacesViewModel.swift
//  NearbyPlacesApp
//
//  Created by Noman belim on 02/01/26.
//
import Foundation
import CoreLocation

final class PlacesViewModel: ObservableObject {

    @Published var places: [Place] = []
    @Published var isLoading: Bool = false   // ✅ REQUIRED

    private let apiService = PlacesAPIService()

    func search(text: String, location: CLLocation?) {
        guard let location,
              text.trimmingCharacters(in: .whitespaces).count > 1
        else {
            places = []
            return
        }

        isLoading = true

        apiService.searchPlaces(
            query: text,
            location: location
        ) { [weak self] places in
            DispatchQueue.main.async {
                self?.places = places
                self?.isLoading = false
            }
        }
    }
}
