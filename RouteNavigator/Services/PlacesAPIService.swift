//
//  PlacesAPIService.swift
//  NearbyPlacesApp
//
//  Created by Noman belim on 02/01/26.
//

import Foundation
import Foundation
import CoreLocation

final class PlacesAPIService {

    private let apiKey = "AIzaSyCqafK_zWnJ1h7ZY_KTpsxmHRCQDAZzw_Q"
                           
    func searchPlaces(
           query: String,
           location: CLLocation,
           completion: @escaping ([Place]) -> Void
       ) {
           let lat = location.coordinate.latitude
           let lng = location.coordinate.longitude

           let finalQuery = "\(query) near me"
           let encodedQuery =
               finalQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
               ?? finalQuery

           let urlString =
           "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(encodedQuery)&location=\(lat),\(lng)&radius=10000&key=\(apiKey)"

           print("🌐 REQUEST URL:\n", urlString)

           guard let url = URL(string: urlString) else {
               print("❌ Invalid URL")
               return
           }

           URLSession.shared.dataTask(with: url) { data, _, error in

               if let error {
                   print("❌ Network error:", error.localizedDescription)
                   return
               }

               guard let data else {
                   print("❌ No data received")
                   return
               }

               // 🔍 PRINT RAW RESPONSE
               let raw = String(data: data, encoding: .utf8) ?? ""
               print("📦 RAW RESPONSE:\n", raw)

               guard
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? String
               else {
                   print("❌ Invalid JSON")
                   return
               }

               print("✅ API STATUS:", status)

               if status != "OK" {
                   print("❌ Google API error:", json)
                   DispatchQueue.main.async {
                       completion([])
                   }
                   return
               }

               let results = json["results"] as? [[String: Any]] ?? []

               let places = results.compactMap { item -> Place? in
                   guard
                       let name = item["name"] as? String,
                       let geometry = item["geometry"] as? [String: Any],
                       let location = geometry["location"] as? [String: Any],
                       let lat = location["lat"] as? CLLocationDegrees,
                       let lng = location["lng"] as? CLLocationDegrees
                   else { return nil }

                   let address =
                       (item["formatted_address"] as? String) ??
                       (item["vicinity"] as? String) ??
                       "No address"

                   return Place(
                       name: name,
                       address: address,
                       coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)
                   )
               }

               DispatchQueue.main.async {
                   completion(places)
               }

           }.resume()
       }
   }
