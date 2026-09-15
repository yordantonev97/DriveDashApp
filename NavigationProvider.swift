import Foundation

enum NavigationProvider: String, CaseIterable, Identifiable {
    case waze = "Waze"
    case googleMaps = "Google Maps"

    var id: String { rawValue }

    var launchURL: URL? {
        switch self {
        case .waze:
            return URL(string: "https://waze.com/ul?navigate=yes")
        case .googleMaps:
            return URL(string: "https://www.google.com/maps/dir/?api=1")
        }
    }
}
