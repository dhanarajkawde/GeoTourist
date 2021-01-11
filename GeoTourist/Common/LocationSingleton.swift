//
//  LocationSingleton.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 11/01/21.
//

import Foundation
import CoreLocation

/// Location Class
class LocationSingleton: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var latitude = 0.0
    private var longitude = 0.0
    
    static let shared = LocationSingleton()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization() // you might replace this with whenInuse
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
            print("\(Localizable.Lat)=\(latitude), \(Localizable.Long)=\(longitude), \(Localizable.Time)=\(Date())")
        }
    }
    
    /// Get Latitude
    /// - Returns: description
    func getLatitude() -> CLLocationDegrees {
        return latitude
    }
    
    /// Get Longitude
    /// - Returns: description
    func getLongitude() -> CLLocationDegrees {
        return longitude
    }
}
