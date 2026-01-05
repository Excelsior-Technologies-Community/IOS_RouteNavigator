//
//   RouteHelper.swift
//  NearbyPlacesApp
//
//  Created by Noman belim on 02/01/26.
//

import Foundation
import MapKit
import MapKit

func openNavigation(
    from source: CLLocationCoordinate2D,
    to destination: CLLocationCoordinate2D,
    name: String
) {
    let destinationItem = MKMapItem(
        placemark: MKPlacemark(coordinate: destination)
    )
    destinationItem.name = name

    let sourceItem = MKMapItem(
        placemark: MKPlacemark(coordinate: source)
    )

    MKMapItem.openMaps(
        with: [sourceItem, destinationItem],
        launchOptions: [
            MKLaunchOptionsDirectionsModeKey:
                MKLaunchOptionsDirectionsModeDriving
        ]
    )
}
final class RouteHelper {

    static func calculateRoute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        completion: @escaping (String, String) -> Void
    ) {
        let request = MKDirections.Request()
        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: source)
        )
        request.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: destination)
        )
        request.transportType = .automobile

        MKDirections(request: request).calculate { response, _ in
            guard let route = response?.routes.first else { return }

            let distanceKM = route.distance / 1000
            let timeMin = route.expectedTravelTime / 60

            let distanceText = String(format: "%.1f km", distanceKM)
            let timeText = String(format: "%.0f min", timeMin)

            completion(distanceText, timeText)
        }
    }
}
