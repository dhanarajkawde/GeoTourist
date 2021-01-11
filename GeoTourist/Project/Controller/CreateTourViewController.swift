//
//  CreateTourViewController.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 05/01/21.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreData

/// Class to create New Tour
class CreateTourViewController: BaseViewController, CLLocationManagerDelegate {
    
    // MARK:- IB Outlets
    @IBOutlet weak var viwTop: UIView!
    @IBOutlet weak var btnFinished: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTourTime: UILabel!
    @IBOutlet weak var tblAddTour: UITableView!
    @IBOutlet weak var viwMap: GMSMapView!
    
    // MARK:- Variavle Declaration
    var locationManager = CLLocationManager()
    var marker = GMSMarker()
    var arrLocations = [LocationDetails]()
    var polyline = GMSPolyline()
    var tappedMarker = GMSMarker()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let imagePickerController = UIImagePickerController()
    var selectedMarker = 0
    
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnFinished.addTarget(self, action: #selector(finishedClicked), for: .touchUpInside)
        
        self.tblAddTour.register(UINib(nibName: Constants.AddStopTableViewCell, bundle: .main), forCellReuseIdentifier: Constants.AddStopTableViewCell)
        
        // Creates a marker in the center of the map.
        marker.title = Localizable.MyCurrentLocation
        marker.snippet = Localizable.User
        marker.icon = UIImage(named: "current-location")
        marker.map = viwMap
        
        let camera = GMSCameraPosition.camera(withLatitude: LocationSingleton.shared.getLatitude(), longitude: LocationSingleton.shared.getLongitude(), zoom: 10.0)
        self.viwMap?.animate(to: camera)
        
        marker.position = CLLocationCoordinate2D(latitude: LocationSingleton.shared.getLatitude(), longitude: LocationSingleton.shared.getLongitude())
    }
    
    /// Go back to Home Controller
    /// - Parameter sender: sender description
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Complete new tour
    /// - Parameter sender: sender description
    @objc func finishedClicked(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: Localizable.AddNewTour, message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = Localizable.EnterTourName
        }
        let saveAction = UIAlertAction(title: Localizable.Save, style: UIAlertAction.Style.default, handler: { alert -> Void in
            let tourName = alertController.textFields![0] as UITextField
            
            let newTour = Tour(context: self.context)
            newTour.tourId = UUID().uuidString
            newTour.tourName = tourName.text ?? ""
            
            for location in self.arrLocations {
                
                let newLocation = Location(context: self.context)
                newLocation.lat = Double(location.coordinate?.latitude ?? 0)
                newLocation.long = Double(location.coordinate?.longitude ?? 0)
                newLocation.video = location.video
                newLocation.name = location.name
                newLocation.locationId = location.locationId
                newLocation.color = location.color
                
                newTour.addToConsistLocations(newLocation)
            }
            
            self.saveItems()
        })
        let cancelAction = UIAlertAction(title: Localizable.Cancel, style: UIAlertAction.Style.default, handler: {
                                            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Remove added location in tour
    /// - Parameter sender: sender description
    @objc func btnCrossClicked(_ sender: UIButton) {
        
        self.arrLocations.remove(at: sender.tag)
        
        self.viwMap.clear()
        
        for i in 0..<self.arrLocations.count {
            
            let loc = GMSMarker()
            loc.position = CLLocationCoordinate2D(latitude: self.arrLocations[i].coordinate!.latitude, longitude: self.arrLocations[i].coordinate!.longitude)
            loc.snippet = self.arrLocations[i].name
            loc.userData = UserData(placeId: self.arrLocations[i].locationId)
            loc.icon = GMSMarker.markerImage(with: UIColor(hexString: self.arrLocations[i].color!))
            loc.map = self.viwMap
            
            if i > 0 {
                let source = i - 1
                let destinatoin = i
                self.drawPath(startLocation: CLLocation(latitude: self.arrLocations[source].coordinate!.latitude, longitude: self.arrLocations[source].coordinate!.longitude), endLocation: CLLocation(latitude: self.arrLocations[destinatoin].coordinate!.latitude, longitude: self.arrLocations[destinatoin].coordinate!.longitude))
            }
            else {
                let camera = GMSCameraPosition.camera(withLatitude: self.arrLocations[i].coordinate!.latitude, longitude: self.arrLocations[i].coordinate!.latitude, zoom: 10.0)
                self.viwMap?.animate(to: camera)
            }
        }
        
        self.tblAddTour.reloadData()
        let indexPath = IndexPath(row: self.arrLocations.count, section: 0)
        self.tblAddTour.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    /// Save Tour to Core Data
    func saveItems() {
        
        do {
            try context.save()
            
            self.navigationController?.popViewController(animated: true)
        }
        catch {
            
            print("error saving context")
        }
    }
    
    /// Draw path between location
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
    /// - Parameter points: points description
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
    
    /// Generate random number
    /// - Parameter color: color description
    /// - Returns: description
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 160)), lroundf(Float(g * 180)), lroundf(Float(b * 200)))
        print(hexString)
        return hexString
    }
}

// MARK:- GMSAutocompleteViewControllerDelegate
extension CreateTourViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let location = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        print("location: \(location)")
        let clr = UIColor.random()
        
        if self.selectedMarker <= self.arrLocations.count - 1 {
            
            self.viwMap.clear()
            
            self.arrLocations[self.selectedMarker].coordinate = place.coordinate
            self.arrLocations[self.selectedMarker].name = place.name
            self.arrLocations[self.selectedMarker].color = self.hexStringFromColor(color: clr)
            self.arrLocations[self.selectedMarker].locationId = place.placeID
            
            for i in 0..<self.arrLocations.count {
                
                let loc = GMSMarker()
                loc.position = CLLocationCoordinate2D(latitude: self.arrLocations[i].coordinate!.latitude, longitude: self.arrLocations[i].coordinate!.longitude)
                loc.snippet = self.arrLocations[i].name
                loc.userData = UserData(placeId: self.arrLocations[i].locationId)
                loc.icon = GMSMarker.markerImage(with: UIColor(hexString: self.arrLocations[i].color!))
                loc.map = self.viwMap
                
                if i > 0 {
                    let source = i - 1
                    let destinatoin = i
                    self.drawPath(startLocation: CLLocation(latitude: self.arrLocations[source].coordinate!.latitude, longitude: self.arrLocations[source].coordinate!.longitude), endLocation: CLLocation(latitude: self.arrLocations[destinatoin].coordinate!.latitude, longitude: self.arrLocations[destinatoin].coordinate!.longitude))
                }
                else {
                    let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom: 10.0)
                    self.viwMap?.animate(to: camera)
                }
            }
        }
        else {
            let loc = GMSMarker()
            loc.position = location
            loc.snippet = place.name
            loc.map = self.viwMap
            loc.userData = UserData(placeId: place.placeID)
            loc.icon = GMSMarker.markerImage(with: clr)
            
            let details = LocationDetails()
            details.coordinate = place.coordinate
            details.name = place.name
            details.color = self.hexStringFromColor(color: clr)
            details.locationId = place.placeID
            
            self.arrLocations.append(details)
            
            if self.arrLocations.count > 1 {
                let source = self.arrLocations.count - 2
                let destinatoin = self.arrLocations.count - 1
                self.drawPath(startLocation: CLLocation(latitude: self.arrLocations[source].coordinate!.latitude, longitude: self.arrLocations[source].coordinate!.longitude), endLocation: CLLocation(latitude: self.arrLocations[destinatoin].coordinate!.latitude, longitude: self.arrLocations[destinatoin].coordinate!.longitude))
            }
            else {
                let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom: 10.0)
                self.viwMap?.animate(to: camera)
            }
        }
        self.tblAddTour.reloadData()
        let indexPath = IndexPath(row: self.arrLocations.count, section: 0)
        self.tblAddTour.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension CreateTourViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrLocations.count > 0 ? (self.arrLocations.count + 1) : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let addStopTableViewCell:AddStopTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.AddStopTableViewCell, for: indexPath) as! AddStopTableViewCell
        addStopTableViewCell.txtAddStop.tag = indexPath.row
        addStopTableViewCell.btnCross.tag = indexPath.row
        addStopTableViewCell.lblHeader.tag = indexPath.row
        addStopTableViewCell.txtAddStop.delegate = self
        addStopTableViewCell.btnCross.addTarget(self, action: #selector(self.btnCrossClicked(_:)), for: .touchUpInside)
        
        addStopTableViewCell.lblHeader.text = "\(indexPath.row + 1)"
        addStopTableViewCell.lblHeader.layer.cornerRadius = 12.5
        addStopTableViewCell.lblHeader.layer.borderWidth = 1.0
        addStopTableViewCell.lblHeader.layer.borderColor = UIColor.black.cgColor
        
        if self.arrLocations.count > 0 && indexPath.row < self.arrLocations.count {
            addStopTableViewCell.txtAddStop.text = self.arrLocations[indexPath.row].name
        }
        else {
            addStopTableViewCell.txtAddStop.text = ""
        }
        
        if indexPath.row == 0 || ((indexPath.row + 1) == (self.arrLocations.count + 1)) {
            addStopTableViewCell.btnCross.isHidden = true
            if self.arrLocations.count == 2 && indexPath.row == 1 {
                addStopTableViewCell.btnCross.isHidden = false
            }
        }
        else {
            addStopTableViewCell.btnCross.isHidden = false
        }
        
        return addStopTableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK:- UITextFieldDelegate
extension CreateTourViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.selectedMarker = textField.tag
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        return true
    }
}

// MARK:- GMSMapViewDelegate
extension CreateTourViewController : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        if marker.snippet != Localizable.User {
            
            let alert = UIAlertController(title: "", message: Localizable.AddVideo, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: Localizable.Yes, style: .default, handler: { [self] _ in
                
                let placeId = (marker.userData as! UserData).placeId
                let selectedMarker = self.arrLocations.indices.filter({self.arrLocations[$0].locationId == placeId})
                self.selectedMarker = selectedMarker[0]
                
                self.imagePickerController.delegate = self
                self.imagePickerController.mediaTypes = ["public.movie"]
                self.imagePickerController.videoQuality = .typeHigh
                
                self.present(imagePickerController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: Localizable.No, style: .cancel, handler: { _ in
                print("no")
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 40))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        
        let lbl1 = UILabel(frame: CGRect.init(x: 10, y: 12, width: view.frame.size.width - 30, height: 15))
        lbl1.text = marker.snippet
        view.addSubview(lbl1)
        
        let btn = UIButton(frame: CGRect.init(x: 70, y: 5, width: 30, height: 30))
        btn.setImage(UIImage(named: "round-info-button"), for: .normal)
        view.addSubview(btn)
        
        return view
    }
}

// MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CreateTourViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let url = info[.mediaURL] as? URL {
            
            do {
                let filePath = self.documentsPathForFileName(name: "/\(url.lastPathComponent)")
                let videoAsData = try! Data(contentsOf: url)
                try videoAsData.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                self.arrLocations[self.selectedMarker].video = filePath
            } catch {
                print(error)
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Set path of video
    /// - Parameter name: name description
    /// - Returns: description
    func documentsPathForFileName(name: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath.appending(name)
    }
}
