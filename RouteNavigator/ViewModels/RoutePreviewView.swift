//
//  RoutePreviewView.swift
//  NearbyPlacesApp
//
//  Created by Noman belim on 02/01/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct RoutePreviewView: View {

    let userLocation: CLLocationCoordinate2D
    let destination: Place

    @State private var distanceText = "--"
    @State private var timeText = "--"
    @State private var region: MKCoordinateRegion

    init(userLocation: CLLocationCoordinate2D, destination: Place) {
        self.userLocation = userLocation
        self.destination = destination

        // 📍 Region that includes BOTH user & destination
        let centerLat = (userLocation.latitude + destination.coordinate.latitude) / 2
        let centerLng = (userLocation.longitude + destination.coordinate.longitude) / 2

        let latDelta = abs(userLocation.latitude - destination.coordinate.latitude) * 2
        let lngDelta = abs(userLocation.longitude - destination.coordinate.longitude) * 2

        _region = State(
            initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: centerLat,
                    longitude: centerLng
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: max(latDelta, 0.02),
                    longitudeDelta: max(lngDelta, 0.02)
                )
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {

            // 🗺️ MAP WITH BOTH LOCATIONS
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: [destination]
            ) { place in
                MapMarker(
                    coordinate: place.coordinate,
                    tint: .red
                )
            }
            .frame(height: 620)
            
            // 📏 ROUTE INFO
            VStack(spacing: 12) {
                Text(destination.name)
                    .font(.headline)

                HStack {
                    Label(distanceText, systemImage: "location")
                    Spacer()
                    Label(timeText, systemImage: "clock")
                }
                .font(.subheadline)

                Button {
                    openNavigation()
                } label: {
                    Text("Start Navigation")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Route Preview")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calculateRoute()
        }
    }

    // MARK: - Route calculation

    private func calculateRoute() {
        let request = MKDirections.Request()
        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: userLocation)
        )
        request.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: destination.coordinate)
        )
        request.transportType = .automobile

        MKDirections(request: request).calculate { response, _ in
            guard let route = response?.routes.first else { return }

            distanceText = String(format: "%.1f km", route.distance / 1000)
            timeText = String(format: "%.0f min", route.expectedTravelTime / 60)
        }
    }

    // MARK: - Open Apple Maps

    private func openNavigation() {
        let destItem = MKMapItem(
            placemark: MKPlacemark(coordinate: destination.coordinate)
        )
        destItem.name = destination.name

        let sourceItem = MKMapItem(
            placemark: MKPlacemark(coordinate: userLocation)
        )

        MKMapItem.openMaps(
            with: [sourceItem, destItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey:
                    MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }

    // MARK: - Helper (Map positioning)

    private func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        let x = CGFloat((coordinate.longitude - region.center.longitude)
            / region.span.longitudeDelta + 0.5)

        let y = CGFloat((region.center.latitude - coordinate.latitude)
            / region.span.latitudeDelta + 0.5)

        return CGPoint(x: UIScreen.main.bounds.width * x, y: 160 * y)
    }
}
