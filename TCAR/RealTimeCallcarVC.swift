//
//  RealTimeCallcarVC.swift
//  TCAR
//
//  Created by Chris on 2017/9/26.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

enum Location {
    case startLocation
    case destinationLocation
}

enum GetLocationError: Error {
    case locationManagerProblem
    case notGetlatitudeandlongitude
    case notOpenPositionign
}

class RealTimeCallcarVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!
    @IBOutlet weak var number_PickerTextField: UITextField!
    @IBOutlet weak var note_TextField: UITextField!
    
    /* Variable */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var markerStart = GMSMarker()
    var markerEnd = GMSMarker()
    
    let pickerView = UIPickerView()
    var passenger_Number = 0
    var pickOption = ["Select:","1", "2", "3", "4", "5", "6", "7", "8"]
    var lat_lng_Array = [Double]()
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the custom NavigationBar func.
        setupNavigationBarItems()

        // Setting LocatinManager parameters.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()

        self.googleMaps.delegate = self
        self.googleMaps.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        
        // Locate the current location for the first time
        initGoogleMapView()
        
        // Setting Number of Passenger PickerView.
        pickerView.delegate = self
        pickerView.dataSource = self
        number_PickerTextField.inputView = pickerView
        
        // Setting first pickOption Array with Language.
        pickOption[0] = NSLocalizedString("PRTCV_Select", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        // Judgment RealTimeCallCar back to root page.
        if UserDefaults.standard.bool(forKey: "PRTCVC_root_switch") {
            self.navigationController?.popViewController(animated: true)
        } else {
            UserDefaults.standard.set(true, forKey: "PRTCVC_root_switch")
            UserDefaults.standard.synchronize()
        }
    }
    
    /*
     # MARK: - Picker Delegate Methods #
     */
    
    // Setting PickerView Count.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Setting PickerView Component rows count.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    // Setting PickerView Component all title.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    // User select picker end, Setting textfield = select.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            self.passenger_Number = Int(pickOption[row])!
            number_PickerTextField.text = pickOption[row] + " " + NSLocalizedString("PRTCV_Member", comment: "")
        }
    }
    
    /*
     # MARK: - Location Manager Delegate Methods #
     */
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Finally stop updating location otherwise it will come again and again in this delegate.
        self.locationManager.stopUpdatingLocation()
    }


    /*
     # MARK: - GMSMapView Manager Delegate Methods #
     */
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMaps.isMyLocationEnabled = true
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMaps.isMyLocationEnabled = true

        if (gesture) {
            mapView.selectedMarker = nil
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMaps.isMyLocationEnabled = true
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps.isMyLocationEnabled = true
        googleMaps.selectedMarker = nil
        return false
    }
    
    /*
     # MARK: - IBAction Methods. #
     */
    
    // When start location tap, this will open the search location
    @IBAction func openStartLocation(_ sender: UIButton) {
        // Set RTCVC back root page switch for false.
        UserDefaults.standard.set(false, forKey: "PRTCVC_root_switch")
        UserDefaults.standard.synchronize()
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .startLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    // When destination location tap, this will open the search location
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        // Set RTCVC back root page switch for false.
        UserDefaults.standard.set(false, forKey: "PRTCVC_root_switch")
        UserDefaults.standard.synchronize()
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .destinationLocation
        
        // Change text color
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        self.locationManager.stopUpdatingLocation()
        
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    // API: Add Order , Method: POST.
    @IBAction func realTimeCallCar_Button(_ sender: UIButton) {
        let headers = TCAR_API.getHeader_HasSession()

        // If User Device not have network.
        if currentReachabilityStatus == .notReachable {
            // Display Alert message.
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_NoNetwork", comment: ""),
                message: NSLocalizedString("NoNetwork", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            return
        } else if ((startLocation.text?.isEmpty)! || (destinationLocation.text?.isEmpty)! || (number_PickerTextField.text?.isEmpty)!) {
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_Incomplete", comment: ""),
                message: NSLocalizedString("AllFieldNeedCorrect", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            return
        } else {
            let parameters: [String : Any] = [
                "pickup_lat": self.lat_lng_Array[0],
                "pickup_lng": self.lat_lng_Array[1],
                "pickup_note": startLocation.text!,
                "dest_note": destinationLocation.text!,
                "person": passenger_Number,
                "note": note_TextField.text!
            ]
            
            // Wait Backend modify parameters. #Chris - 180126.
            /*
            let parameters: [String : Any] = [
                "pickup_lat": self.lat_lng_Array[0],
                "pickup_lng": self.lat_lng_Array[1],
                "pickup_note": startLocation.text!,
                "dest_lat" : self.lat_lng_Array[2],
                "dest_lng" : self.lat_lng_Array[3],
                "dest_note": destinationLocation.text!,
                "person": passenger_Number,
                "note": note_TextField.text!
            ]
            */
            
            AccessAPIs.sendRequest_hasParameters(url: TCAR_API.getRTCC_Add_URL(), method: .post, headers: headers, parameters: parameters) {
                response, error in
                
                let json = JSON(response as Any)
                guard json["error_code"].intValue == 0 else {
                    // Login is failure.
                    DispatchQueue.main.async {
                        UIAlertController.OB_showConfirmAlert(
                            title: NSLocalizedString("PRTCV_CallCar_Fail", comment: ""),
                            message: json["error_message"].stringValue,
                            alertTitle: NSLocalizedString("Cancel", comment: ""),
                            in: self) { (_) in
                                self.navigationController?.popViewController(animated: true)
                        }
                    }
                    return
                }
                
                let RTCOrder_id = json["task"]["id"].intValue
                print("Passenger Real Time Call Order is : \(String(RTCOrder_id))")
                DispatchQueue.main.async {
                    // Write RealTimeCall Order index to the local data.
                    UserDefaults.standard.set(RTCOrder_id, forKey: "RTCO_id")
                    UserDefaults.standard.synchronize()
                    // Transfer WaitDriver ViewController.
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Wait_DriverVC")
                    self.present(vc!, animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    // Setup NavigationBar Title.
    private func setupNavigationBarItems() {
        navigationItem.title = NSLocalizedString("PRTCV_Navigation_Title", comment: "")
    }
    
    // Initialization mapView.
    func initGoogleMapView() {
        do {
            // Try Can get the current location?
            try checkGetLocation()
            // Get current location.
            let location = self.locationManager.location
            let latitude = self.locationManager.location?.coordinate.latitude
            let longitude = self.locationManager.location?.coordinate.longitude
            self.lat_lng_Array.removeAll()
            self.lat_lng_Array.append(latitude!)
            self.lat_lng_Array.append(longitude!)
            // If can get location, setting current location to GoogleMap.
            setGoogleMapWhenStart(location: location!, latitude: self.lat_lng_Array[0], longitude: self.lat_lng_Array[1], status: true)
        } catch GetLocationError.locationManagerProblem {
            UIAlertController.OB_showConfirmAlert(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Check_LS", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self) { (_) in
                    self.navigationController?.popViewController(animated: true)
            }
        } catch GetLocationError.notGetlatitudeandlongitude {
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("LS_Fail", comment: ""),
                message: NSLocalizedString("Enter_SL", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            // If can not get current location, default located in the city center.
            // Need user key in new location information.
            let location = self.locationManager.location
            setGoogleMapWhenStart(location: location!, latitude: 24.5721594, longitude: 120.8148985, status: false)
        } catch GetLocationError.notOpenPositionign {
            UIAlertController.OB_showConfirmAlert(
                title: NSLocalizedString("LS_isDisable", comment: ""),
                message: NSLocalizedString("GoSetting_LS", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self) { (_) in
                    self.navigationController?.popViewController(animated: true)
            }
        } catch {
            UIAlertController.OB_showConfirmAlert(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Unknow_Error", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self) { (_) in
                    self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: function for Check Can get location.
    func checkGetLocation() throws {
        guard self.locationManager.location != nil else {
            throw GetLocationError.locationManagerProblem
        }
        guard self.locationManager.location?.coordinate.latitude != nil && self.locationManager.location?.coordinate.longitude != nil else {
            throw GetLocationError.notGetlatitudeandlongitude
        }
        guard CLLocationManager.authorizationStatus() != .denied else {
            throw GetLocationError.notOpenPositionign
        }
    }
    
    // MARK: funcion for Setting Start MapView.
    func setGoogleMapWhenStart(location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees, status: Bool) {
        // Set Camera to the now location and Mark current location.
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        self.googleMaps.camera = camera
        
        if status {
            // Set First Marker in the current location , and Set locationStart in the now.
            self.createMarker(type: "Start", titleMarker: NSLocalizedString("PRTCV_Start_Location", comment: ""), iconMarker: #imageLiteral(resourceName: "mapspin"), latitude: latitude, longitude: longitude)
            locationStart = CLLocation(latitude: latitude, longitude: longitude)

            // Reverse CLlocation to the format address.
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                // Place details
                let placeMark = placemarks?[0]
                var addressDictionary = placeMark?.addressDictionary
                var addressString = ""
                
                // Get Place All details.
                // Chris - 180125.
                // if let postalCode = addressDictionary!["ZIP"] as? String { addressString += postalCode }
                // if let country = addressDictionary!["Country"] as? String { addressString += country }
                if let subAdministrativeArea = addressDictionary!["SubAdministrativeArea"] as? String {
                    addressString += subAdministrativeArea
                }
                if let locality = addressDictionary!["City"] as? String { addressString += locality }
                if let thoroughfare = addressDictionary!["Thoroughfare"] as? String {
                    addressString += thoroughfare
                }
                if let subThoroughfare = addressDictionary!["SubThoroughfare"] as? String {
                    addressString += subThoroughfare + "號"
                }
                
                // Setting startLocation is now Location.
                self.startLocation.text = addressString
            }
        }
    }
    
    // MARK: function for create a marker pin on map.
    func createMarker(type: String, titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        if type == "Start" {
            self.markerStart.position = CLLocationCoordinate2DMake(latitude, longitude)
            self.markerStart.title = titleMarker
            self.markerStart.icon = iconMarker
            self.markerStart.map = googleMaps
            
        } else {
            self.markerEnd.position = CLLocationCoordinate2DMake(latitude, longitude)
            self.markerEnd.title = titleMarker
            self.markerEnd.icon = iconMarker
            self.markerEnd.map = googleMaps
        }
        
    }
    
}
    
// MARK: - GMS Auto Complete Delegate, for autocomplete search location
extension RealTimeCallcarVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // Change camera location
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0
        )
        
        let address_all = place.formattedAddress!
        var remove_postal = ""
        var remove_country = ""
        var address_text = ""
        
        for component in place.addressComponents! {
            if component.type == "country" {
                let indexStartOfText = address_all.index(address_all.startIndex, offsetBy: component.name.count)
                let temp = address_all[indexStartOfText...]
                remove_postal = String(temp)
            }
            
            if component.type == "postal_code" {
                let indexStartOfText = address_all.index(address_all.startIndex, offsetBy: component.name.count)
                let temp = remove_postal[indexStartOfText...]
                remove_country = String(temp)
            }
        }
        address_text = remove_country
        
        // set coordinate to text
        if locationSelected == .startLocation {
            // Clear other Mark.
            self.markerStart.map?.clear()
            // Setting startLocation text -> formattedAddress.
            startLocation.text = address_text
            
            // Update latitude and longitude.
            if self.lat_lng_Array.count == 2 {
                self.lat_lng_Array.removeAll()
                self.lat_lng_Array.append(place.coordinate.latitude)
                self.lat_lng_Array.append(place.coordinate.longitude)
            } else {
                self.lat_lng_Array.removeFirst()
                self.lat_lng_Array.removeFirst()
                self.lat_lng_Array.insert(place.coordinate.longitude, at: 0)
                self.lat_lng_Array.insert(place.coordinate.latitude, at: 0)
            }
            locationStart = CLLocation(latitude: place.coordinate.latitude, longitude:place.coordinate.longitude)
            createMarker(type: "Start", titleMarker: NSLocalizedString("PRTCV_Start_Location", comment: ""), iconMarker: #imageLiteral(resourceName: "mapspin"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        } else {
            // Clear other Mark.
            self.markerEnd.map?.clear()
            destinationLocation.text = address_text
            // Update latitude and longitude.
            if self.lat_lng_Array.count == 2 {
                self.lat_lng_Array.append(place.coordinate.latitude)
                self.lat_lng_Array.append(place.coordinate.longitude)
            } else {
                self.lat_lng_Array.removeLast()
                self.lat_lng_Array.removeLast()
                self.lat_lng_Array.insert(place.coordinate.longitude, at: 2)
                self.lat_lng_Array.insert(place.coordinate.latitude, at: 2)
            }
            locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            createMarker(type: "End", titleMarker: NSLocalizedString("PRTCV_Destination_Location", comment: ""), iconMarker: #imageLiteral(resourceName: "mapspin"), latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        self.googleMaps.camera = camera
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


// MARK: - GoogleMaps View SearchBar.
public extension UISearchBar {

    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}
