//
//  ContentView.swift
//  NearbyPlacesApp
//
//  Created by Noman belim on 02/01/26.
//
import SwiftUI
import CoreLocation

struct ContentView: View {

    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = PlacesViewModel()

    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 16) {

                    // 📍 LOCATION BAR
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)

                        Text(locationManager.locationName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal)

                    // 🔍 SEARCH BAR
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField(
                            "Search ATM, spa, restaurant...",
                            text: $searchText
                        )
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    .onChange(of: searchText) { newValue in
                        viewModel.search(
                            text: newValue,
                            location: locationManager.location
                        )
                    }

                    // ⏳ LOADING STATE
                    if viewModel.isLoading {
                        ProgressView("Searching nearby places...")
                            .padding(.top, 8)
                    }

                    // 📋 RESULTS
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.places) { place in
                                if let userCoord = locationManager.location?.coordinate {
                                    PlaceCardView(
                                        place: place,
                                        userLocation: userCoord
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.top)
            }
            .navigationTitle("Nearby Places")
        }
    }
}
struct PlaceCardView: View {

    let place: Place
    let userLocation: CLLocationCoordinate2D
    @State private var showRoutePreview = false
    @State private var distance = "--"
    @State private var time = "--"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(place.name)
                .font(.headline)

            Text(place.address)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Label(distance, systemImage: "location")
                Label(time, systemImage: "clock")

                Spacer()
                NavigationLink {
                    RoutePreviewView(
                        userLocation: userLocation,
                        destination: place
                    )
                } label: {
                    Text("Preview Route")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button {
                    openNavigation(
                        from: userLocation,
                        to: place.coordinate,
                        name: place.name
                    )
                } label: {
                    Text("Navigate")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        
        .onAppear {
            RouteHelper.calculateRoute(
                from: userLocation,
                to: place.coordinate
            ) { dist, t in
                distance = dist
                time = t
            }
        }
    }
}
// MARK: - Preview

#Preview {
    ContentView()
}
