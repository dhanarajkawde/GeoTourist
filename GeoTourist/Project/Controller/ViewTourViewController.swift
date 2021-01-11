//
//  ViewTourViewController.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 10/01/21.
//

import UIKit
import GoogleMaps
import AVFoundation
import AVKit

/// class to view saved tour
class ViewTourViewController: BaseViewController {
    
    // MARK:- IB Outlets
    @IBOutlet weak var viwMap: GMSMapView!
    @IBOutlet weak var lblHeader: UILabel!
    
    // MARK:- Variavle Declaration
    var tourDetail:Tour?
    var arrLocation = [Location]()
    var polyline = GMSPolyline()
    
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblHeader.text = self.tourDetail?.tourName
        
        self.arrLocation = self.tourDetail?.consistLocations?.allObjects as! [Location]
                
        for i in 0..<self.arrLocation.count {
            
            let loc = GMSMarker()
            loc.position = CLLocationCoordinate2D(latitude: self.arrLocation[i].lat, longitude: self.arrLocation[i].long)
            loc.snippet = self.arrLocation[i].name
            loc.userData = UserData(placeId: self.arrLocation[i].locationId)
            loc.icon = GMSMarker.markerImage(with: UIColor(hexString: self.arrLocation[i].color!))
            loc.map = self.viwMap
            
            if i > 0 {
                let source = i - 1
                let destinatoin = i
                self.drawPath(startLocation: CLLocation(latitude: self.arrLocation[source].lat, longitude: self.arrLocation[source].long), endLocation: CLLocation(latitude: self.arrLocation[destinatoin].lat, longitude: self.arrLocation[destinatoin].long))
            }
        }
    }
    
    /// go back to home controller
    /// - Parameter sender: sender description
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Draw path between two coordinates
    /// - Parameters:
    ///   - startLocation: startLocation description
    ///   - endLocation: endLocation description
    func drawPath(startLocation: CLLocation, endLocation: CLLocation) {
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        self.polyline.map = nil
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDts45gejmyUgBH_VZuRSJJ8EGBoN9AvK0"
        
        let session = URLSession.shared
        session.dataTask(with: URL(string: url)!) { (data, response, error) in
            
            guard data != nil else {
                return
            }
            do {

                let route = try JSONDecoder().decode(MapPath.self, from: data!)

                if let points = route.routes?.first?.overview_polyline?.points {
                    self.drawPath(with: points)
                }

            } catch let error {

                print("Failed to draw ",error.localizedDescription)
            }
        }.resume()
    }
    
    /// Draw path line
    /// - Parameter points: <#points description#>
    func drawPath(with points : String){

        DispatchQueue.main.async {
            
            let path = GMSPath(fromEncodedPath: points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .red
            polyline.map = self.viwMap
            
            let bounds = GMSCoordinateBounds(path: path!)
            self.viwMap!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
        }
    }
}

// MARK:- GMSMapViewDelegate
extension ViewTourViewController : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        if let placeId = (marker.userData as! UserData).placeId {
            
            let selectedMarker = self.arrLocation.filter({$0.locationId == placeId})
            
            if selectedMarker[0].video != "" || selectedMarker[0].video != nil {
                
                let alert = UIAlertController(title: "", message: Localizable.SeeVideo, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: Localizable.Yes, style: .default, handler: { [self] _ in
                    
                    let selectedMarker = self.arrLocation.filter({$0.locationId == placeId})
                    
                    let videoURL = URL(fileURLWithPath: selectedMarker[0].video!)
                    let player = AVPlayer(url: videoURL)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }))
                alert.addAction(UIAlertAction(title: Localizable.No, style: .cancel, handler: { _ in
                    print("no")
                }))
                
                self.present(alert, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 150, height: 40))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        
        let lbl1 = UILabel(frame: CGRect.init(x: 10, y: 12, width: view.frame.size.width - 30, height: 15))
        lbl1.text = marker.snippet
        view.addSubview(lbl1)
        
        let btn = UIButton(frame: CGRect.init(x: 120, y: 5, width: 30, height: 30))
        btn.setImage(UIImage(named: "round-info-button"), for: .normal)
        view.addSubview(btn)
        
        return view
    }
}
