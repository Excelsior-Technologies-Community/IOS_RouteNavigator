# 📍 RouteNavigator – Nearby Places Finder with Smart Route Preview

A production-ready SwiftUI iOS application that searches for nearby places (ATMs, restaurants, hospitals, spas, etc.), intelligently sorts them by distance, and provides detailed route previews with accurate ETA calculations—just like Google Maps.

---

## ✨ Key Features

- 🔍 **Smart Search** – Find nearby places using natural keywords
- 📍 **Real-time Location** – Automatic location detection with reverse geocoding
- 📏 **Distance Sorting** – Places automatically sorted from nearest to farthest
- 🗺️ **Route Preview** – Visual map preview with distance and ETA
- 🚗 **Native Navigation** – One-tap integration with Apple Maps
- ⚡ **Clean Architecture** – MVVM pattern with separation of concerns
- 🔄 **Loading States** – Smooth UX with progress indicators
- 🎯 **Accurate Results** – Powered by Google Places API with CoreLocation distance calculation

---

## 🏗️ Project Architecture

```
RouteNavigator/
│
├── Views/
│   ├── ContentView.swift              # Main search interface
│   └── RoutePreviewView.swift         # Map-based route preview
│
├── ViewModels/
│   └── PlacesViewModel.swift          # Business logic & state management
│
├── Services/
│   └── PlacesAPIService.swift         # Google Places API integration
│
├── Helpers/
│   ├── LocationManager.swift          # Location services & permissions
│   └── RouteHelper.swift              # Route calculation utilities
│
└── Models/
    └── Place.swift                     # Place data model
```

**Architecture Pattern:** MVVM (Model-View-ViewModel)
- **Models** define data structures
- **Views** handle UI rendering and user interaction
- **ViewModels** manage business logic and state
- **Services** handle external API communication
- **Helpers** provide reusable utility functions

---

## 🚀 How It Works (Complete Flow)

1. **User Location Detection** – App requests location permissions and fetches current coordinates
2. **Search Initiation** – User types search query (e.g., "ATM", "restaurant")
3. **API Request** – Google Places Text Search API called with 10km radius
4. **Distance Calculation** – CoreLocation calculates straight-line distance for each result
5. **Smart Sorting** – Places sorted by nearest distance first
6. **Route Calculation** – MapKit calculates actual driving distance and ETA
7. **UI Updates** – SwiftUI automatically renders sorted results with route information

---

## 💻 Core Components

### 📍 LocationManager.swift
Centralized location service management with permission handling and reverse geocoding.

**Key Implementation:**
```swift
@Published var location: CLLocation?
@Published var locationName: String = "Fetching location..."

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let loc = locations.last else { return }
    location = loc
    reverseGeocode(location: loc)  // Convert coordinates to readable address
}
```
- `@Published` properties trigger automatic UI updates
- Best accuracy ensures precise distance calculations

---

### 📦 Place.swift
Data model representing a place.

```swift
struct Place: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
}
```
- `Identifiable` enables SwiftUI `ForEach` loops
- `UUID` ensures unique identification for each place

---

### 🌐 PlacesAPIService.swift
Handles all Google Places API communication.

**Important Details:**
```swift
let finalQuery = "\(query) near me"  // Improves search relevance
let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(encodedQuery)&location=\(lat),\(lng)&radius=10000&key=\(apiKey)"
```

**⚠️ Critical Note:** Google Places API does **NOT** return distance-sorted results. Manual sorting is required.

---

### 🧠 PlacesViewModel.swift
Business logic layer managing search state and API calls.

```swift
@Published var places: [Place] = []
@Published var isLoading: Bool = false

func search(text: String, location: CLLocation?) {
    guard let location, text.trimmingCharacters(in: .whitespaces).count > 1 else {
        places = []
        return
    }
    
    isLoading = true
    apiService.searchPlaces(query: text, location: location) { [weak self] places in
        DispatchQueue.main.async {
            self?.places = places
            self?.isLoading = false
        }
    }
}
```
- Validates input before making API calls
- Updates UI on main thread for smooth performance

---

### 🖥️ ContentView.swift
Main user interface with real-time search.

**Search Implementation:**
```swift
TextField("Search ATM, spa, restaurant...", text: $searchText)
    .onChange(of: searchText) { newValue in
        viewModel.search(text: newValue, location: locationManager.location)
    }
```

**Results Display:**
```swift
LazyVStack(spacing: 12) {
    ForEach(viewModel.places) { place in
        PlaceCardView(place: place, userLocation: userCoord)
    }
}
```
`LazyVStack` only renders visible cells for performance optimization.

---

### 🗺️ RoutePreviewView.swift
Full-screen map preview with route information.

**Dynamic Region Calculation:**
```swift
let centerLat = (userLocation.latitude + destination.coordinate.latitude) / 2
let centerLng = (userLocation.longitude + destination.coordinate.longitude) / 2
let latDelta = abs(userLocation.latitude - destination.coordinate.latitude) * 2
let lngDelta = abs(userLocation.longitude - destination.coordinate.longitude) * 2
```
Automatically centers map to show both user and destination with proper zoom.

**Route Calculation:**
```swift
MKDirections(request: request).calculate { response, _ in
    guard let route = response?.routes.first else { return }
    distanceText = String(format: "%.1f km", route.distance / 1000)
    timeText = String(format: "%.0f min", route.expectedTravelTime / 60)
}
```

---

### 🛠️ RouteHelper.swift
Reusable route calculation utilities to avoid code duplication.

```swift
static func calculateRoute(
    from source: CLLocationCoordinate2D,
    to destination: CLLocationCoordinate2D,
    completion: @escaping (String, String) -> Void
)
```

---

## 🔐 Google Places API Setup

### Step 1: Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project
3. Navigate to "APIs & Services" → "Library"

### Step 2: Enable Required APIs
- ✅ Places API

### Step 3: Generate API Key
1. Go to "Credentials" → "Create Credentials" → "API Key"
2. Copy the generated key
3. **Restrict the key** (recommended):
   - Application restrictions: iOS apps
   - Add your bundle identifier
   - API restrictions: Select only Places API

### Step 4: Add Key to Project
```swift
// PlacesAPIService.swift
private let apiKey = "YOUR_API_KEY_HERE"
```

### ⚠️ Security Best Practices:
- Never commit API keys to Git
- Restrict key to your bundle ID
- Monitor usage in Google Cloud Console

---

## 📱 Requirements

| Requirement | Version |
|------------|---------|
| iOS | 16.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |
| Internet | Required |

**Frameworks Used:**
- SwiftUI (UI framework)
- CoreLocation (GPS & location services)
- MapKit (Maps & routing)
- Foundation (Networking & data)

---

## 🚀 Installation & Setup

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/RouteNavigator.git
cd RouteNavigator
```

### 2. Add Google API Key
Open `PlacesAPIService.swift` and replace:
```swift
private let apiKey = "YOUR_API_KEY_HERE"
```

### 3. Configure Info.plist
Add location permission description:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby places</string>
```

### 4. Build & Run
1. Open `NearbyPlacesApp.xcodeproj` in Xcode
2. Select a simulator or device
3. Press `Cmd + R` to build and run

---

## 🎯 Why This Architecture Works

### ✅ Design Principles

1. **Google Places Doesn't Sort by Distance**
   - Google returns relevance-based results
   - Manual sorting ensures accuracy
   - CoreLocation provides real distance calculations

2. **MVVM Separation**
   - Views don't know about API details
   - ViewModels handle business logic
   - Easy to test and maintain

3. **Reactive UI with Combine**
   - `@Published` properties auto-update UI
   - No manual view refresh needed
   - Type-safe state management

4. **Async Network Calls**
   - Network calls on background threads
   - UI updates on main thread
   - Prevents app freezing

---

## 🔄 Future Enhancements

### Planned Features
- [ ] ⏱️ Real-time traffic-aware ETA
- [ ] ⭐ Sort by rating + distance combo
- [ ] 📌 Auto-highlight nearest place
- [ ] 🚗 Turn-by-turn navigation preview
- [ ] 💾 Offline caching with Core Data
- [ ] 🔖 Favorite places
- [ ] 🔔 Location-based notifications
- [ ] 📊 Place details (hours, photos, reviews)
- [ ] 🗂️ Filter by category (food, health, finance)

---

## 📚 Technical Highlights

### What Makes This Professional?

✅ **Separation of Concerns** – Each file has one clear responsibility  
✅ **Type Safety** – Strong typing throughout with compiler error checking  
✅ **Memory Management** – `[weak self]` prevents retain cycles  
✅ **User Experience** – Loading states, error handling, permission management  
✅ **Performance** – `LazyVStack` for efficient rendering

### Key Technical Decisions

**Threading Strategy:**
```swift
URLSession.shared.dataTask(with: url) { data, _, error in
    // Network call on background thread
    DispatchQueue.main.async {
        self?.places = places  // UI update on main thread
    }
}
```

**Distance Calculation:**
```swift
let distance = userLocation.distance(from: placeLocation)  // CoreLocation provides accurate distance in meters
```

---
 
