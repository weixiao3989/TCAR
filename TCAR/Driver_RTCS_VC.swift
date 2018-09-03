//
//  Driver_RTCS_VC.swift
//  TCAR
//
//  Created by Chris on 2018/1/2.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import PCLBlurEffectAlert

class Driver_RTCS_VC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var status_Label: UILabel!
    @IBOutlet weak var destination_Label: UILabel!
    @IBOutlet weak var startTask_Button: UIButton!
    @IBOutlet weak var cancelOrder_Button: UIButton!
    @IBOutlet weak var backItem_Button: UIBarButtonItem!
    
    /* Variable */
    let order_id = UserDefaults.standard.string(forKey: "Order_id_For_Driver")
    let user_id = UserDefaults.standard.string(forKey: "User_id_For_Driver")
    var locationManager = CLLocationManager()
    var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var markerStart = GMSMarker()
    var markerEnd = GMSMarker()
    let headers = TCAR_API.getHeader_HasSession()
    var passenger_Phone: String = ""
    var status: String = ""
    var locationTitles: Array = [""]
    var buttonTitles: Array = [""]
    var statusTitles: Array = [""]
    var lat_lng_Array = [Double]()
    
    fileprivate var cancel_Textfield: UITextField? {
        didSet {
            cancel_Textfield?.addTarget(self, action: #selector(Driver_RTCS_VC.textFieldEditingChanged(_:)), for: UIControlEvents.editingChanged)
        }
    }
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cancelOrder_Button.isEnabled = false
        locationTitles.removeAll()
        lat_lng_Array.removeAll()
        
        buttonTitles = [NSLocalizedString("DRTCS_Button_Title_Passenger", comment: ""), NSLocalizedString("DRTCS_Button_Title_Finish", comment: "")]
        statusTitles = [NSLocalizedString("DRTCS_Status_Title_Ready", comment: "") ,NSLocalizedString("DRTCS_Status_Title_Passenger", comment: ""), NSLocalizedString("DRTCS_Status_Title_Doing", comment: "")]
        
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
        
        // Get Order Information.
        self.getOrderInfo()
        // Get User Information.
        self.getUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // First time start MapView.
        self.initMapView()
    }
    
    /*
     # MARK: - IBAction Methods. #
     */
    
    @IBAction func callUser_Button(_ sender: Any) {
        // Telphone Button push down, Cell the Phone.
        let url: NSURL = URL(string: ("TEL://" + passenger_Phone))! as NSURL
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    @IBAction func backItem_Button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startTask_Button(_ sender: Any) {
        switch self.status {
        case "ESTABLISH":
            // Open Cancel Order Button, and Close BackItemBar.
            cancelOrder_Button.isEnabled = true
            backItem_Button.isEnabled = false
            
            // Clear Marker.
            self.markerStart.map?.clear()
            self.markerEnd.map?.clear()
            
            DispatchQueue.main.async {
                // Send Reply API Change Status.
                self.sendReplyAPI(reply: "DRIVER_ACCEPT", reason: nil)
                
                // Navigation Google Map From Driver Loacation to Passenger Location.
                self.navigationMap(start_lat: String(format: "%f", (self.locationManager.location?.coordinate.latitude)!), start_lng: String(format: "%f", (self.locationManager.location?.coordinate.longitude)!), end_lat: String(format: "%f", self.lat_lng_Array[0]), end_lng: String(format: "%f", self.lat_lng_Array[1]))
                
                // Change UI Title.
                self.status_Label.text = self.statusTitles[1]
                self.startTask_Button.setTitle(self.buttonTitles[0], for: .normal)
            }
            break
        case "DRIVER_ACCEPT":
            // Clear Google Map.
            self.googleMaps.clear()
            
            // Reset Google Map and Navigation From Passenger to Distination.
            DispatchQueue.main.async {
                // Send Reply API Change Status.
                self.sendReplyAPI(reply: "DOING", reason: nil)
                
                // Navigation Google Map From Passenger Loacation to Destination.
                self.navigationMap(start_lat: String(format: "%f", (self.locationManager.location?.coordinate.latitude)!), start_lng: String(format: "%f", (self.locationManager.location?.coordinate.longitude)!), end_lat: String(format: "%f", self.lat_lng_Array[2]), end_lng: String(format: "%f", self.lat_lng_Array[3]))
                
                // Change UI Title.
                self.status_Label.text = self.statusTitles[2]
                self.startTask_Button.setTitle(self.buttonTitles[1], for: .normal)
            }
            break
        case "DOING":
            DispatchQueue.main.async {
                // Send Reply API Change Status.
                self.sendReplyAPI(reply: "FINISH", reason: nil)
            }
            
            // Transfer Driver_ScoreVC ViewController.
            UIAlertController.TB_showConfirmAlert(
                title: NSLocalizedString("DRTCS_Thank", comment: ""),
                message: NSLocalizedString("DRTCS_AskRate", comment: ""),
                actionTitles: [NSLocalizedString("DRTCS_GoRate", comment: ""), NSLocalizedString("DRTCS_NoRate", comment: "")],
                in: self,
                actions: [{action_gorate in
                    // Transfer Driver_ScoreVC ViewController.
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Driver_ScoreVC")
                    self.present(vc!, animated: true, completion: nil)
                    },
                    {action_norate in
                        // Delete Order id & User id.
                        UserDefaults.standard.removeObject(forKey: "Order_id_For_Driver")
                        UserDefaults.standard.removeObject(forKey: "User_id_For_Driver")
                        UserDefaults.standard.synchronize()
                        // Dismiss this page.
                        self.dismiss(animated: true, completion: nil)
                    }])
            break
        default:
            break
        }
    }
    
    @IBAction func cancelOrder_Button(_ sender: Any) {
        let alertController = PCLBlurEffectAlertController(
            title: NSLocalizedString("DRTCS_CancelOrder_Title", comment: ""),
            message: NSLocalizedString("DRTCS_CancelOrder_Message", comment: ""),
            style: .alert)
        alertController.addTextField { (textField: UITextField!) in
            textField.placeholder = NSLocalizedString("DRTCS_CancelOrder_Placeholder", comment: "")
            self.cancel_Textfield = textField
        }
        alertController.configure(textFieldsViewBackgroundColor: UIColor.white.withAlphaComponent(0.1))
        alertController.configure(textFieldBorderColor: .black)
        alertController.configure(buttonDisableTextColor: [.default: .lightGray, .destructive: .lightGray])
        let sendAction = PCLBlurEffectAlertAction(title: NSLocalizedString("DRTCS_CancelOrder_Send", comment: ""), style: .destructive) { (action) in
            
            let textField = self.cancel_Textfield?.text
            DispatchQueue.main.async {
                self.sendReplyAPI(reply: "DRIVER_CANCEL", reason: textField!)
                self.dismiss(animated: true, completion: nil)
            }
        }
        let cancelAction = PCLBlurEffectAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in }
        sendAction.isEnabled = false
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        alertController.show()
    }

    /*
     * // MARK: - Customize Function.
     */
    
    // Get Order Information Function.
    private func getOrderInfo() {
        // If User Device not have network.
        if currentReachabilityStatus == .notReachable {
            // Display Alert message.
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_NoNetwork", comment: ""),
                message: NSLocalizedString("NoNetwork", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            return
        }
        
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getListInfo_URL(_id: order_id!), method: .get, headers: headers) {
            response, error in
            
            let json = JSON(response as Any)
            guard json["error_code"].intValue == 0 else {
                DispatchQueue.main.async {
                    UIAlertController.OB_showNormalAlert(
                        title: NSLocalizedString("Title_Fail", comment: ""),
                        message: json["error_message"].stringValue,
                        alertTitle: NSLocalizedString("Cancel", comment: ""),
                        in: self)
                }
                return
            }
            self.status = json["task"]["status"].stringValue
            
            if (self.status == "ESTABLISH") {
                self.lat_lng_Array.append(json["task"]["pickup_lat"].doubleValue)
                self.lat_lng_Array.append(json["task"]["pickup_lng"].doubleValue)
                // Wait Backend modify parameters. #Chris - 180125.
                // self.lat_lng_Array.append(json["task"]["dest_lat"].doubleValue)
                // self.lat_lng_Array.append(json["task"]["dest_lng"].doubleValue)
                self.lat_lng_Array.append(24.805839)
                self.lat_lng_Array.append(120.977353)
                self.locationTitles.append(json["task"]["pickup_note"].stringValue)
                self.locationTitles.append(json["task"]["dest_note"].stringValue)
                self.status_Label.text = self.statusTitles[0]
                self.destination_Label.text = self.locationTitles[0]
            }
        }
    }
    
    // Get User Information Function.
    private func getUserInfo() {
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getUserInfo_URL(_id: user_id!), method: .get, headers: headers) {
            response, error in
            
            let json = JSON(response as Any)
            guard json["error_code"].intValue == 0 else {
                DispatchQueue.main.async {
                    UIAlertController.OB_showNormalAlert(
                        title: NSLocalizedString("Title_Fail", comment: ""),
                        message: json["error_message"].stringValue,
                        alertTitle: NSLocalizedString("Cancel", comment: ""),
                        in: self)
                }
                return
            }
            self.passenger_Phone = json["member"]["cellphone"].stringValue
        }
    }
    
    // Send Reply API Function.
    private func sendReplyAPI(reply: String, reason: String?) {
        let parameters: [String : Any]
        
        if (reply == "DRIVER_CANCEL") {
            parameters = [
                "taxi_task_id": Int(order_id!)!,
                "reply": reply,
                "cancel_reason": reason!
            ]
        } else {
            parameters = [
                "taxi_task_id": Int(order_id!)!,
                "reply": reply
            ]
        }
        
        AccessAPIs.sendRequest_hasParameters(url: TCAR_API.getReplyURL(), method: .post, headers: headers, parameters: parameters) { response, error in
            
            let json = JSON(response as Any)
            guard json["error_code"].intValue == 0 else {
                DispatchQueue.main.async {
                    UIAlertController.OB_showConfirmAlert(
                        title: NSLocalizedString("Title_Fail", comment: ""),
                        message: json["error_message"].stringValue,
                        alertTitle: NSLocalizedString("Cancel", comment: ""),
                        in: self) { (_) in
                            self.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
            self.status = json["task"]["status"].stringValue
            if (reply == "DRIVER_CANCEL") {
                // Delete Order id & User id.
                UserDefaults.standard.removeObject(forKey: "Order_id_For_Driver")
                UserDefaults.standard.removeObject(forKey: "User_id_For_Driver")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    // Initialization Google mapView.
    private func initMapView() {
        do {
            // Try Can get the current location?
            try checkGetLocation()
            
            // Get current location.
            let latitude = self.locationManager.location?.coordinate.latitude
            let longitude = self.locationManager.location?.coordinate.longitude
            
            // If can get location, setting current location to GoogleMap.
            let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 15.0)
            self.googleMaps.camera = camera
            
            // Set First Marker in the current location , and Set StartLocation & EndLocation in the now.
            self.createMarker(type: "Start", titleMarker: NSLocalizedString("DPRTCV_Driver_Location", comment: ""), iconMarker: #imageLiteral(resourceName: "mapspin"), latitude: latitude!, longitude: longitude!)
            locationStart = CLLocation(latitude: latitude!, longitude: longitude!)
            
            self.createMarker(type: "End", titleMarker: NSLocalizedString("DPRTCV_Passenger_Location", comment: ""), iconMarker: #imageLiteral(resourceName: "mapspin"), latitude: self.lat_lng_Array[0], longitude: self.lat_lng_Array[1])
            locationEnd = CLLocation(latitude: self.lat_lng_Array[0], longitude: self.lat_lng_Array[1])
            
        } catch GetLocationError.locationManagerProblem {
            UIAlertController.OB_showConfirmAlert(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Check_LS", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self) { (_) in
                    self.dismiss(animated: true, completion: nil)
            }
        } catch GetLocationError.notGetlatitudeandlongitude {
            UIAlertController.OB_showConfirmAlert(
                title: NSLocalizedString("LS_Fail", comment: ""),
                message: NSLocalizedString("Enter_SL", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self) { (_) in
                    self.dismiss(animated: true, completion: nil)
            }
        } catch GetLocationError.notOpenPositionign {
            UIAlertController.OB_showConfirmAlert(
                title: NSLocalizedString("LS_isDisable", comment: ""),
                message: NSLocalizedString("GoSetting_LS", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self) { (_) in
                    self.dismiss(animated: true, completion: nil)
            }
        } catch {
            UIAlertController.OB_showConfirmAlert(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Unknow_Error", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self) { (_) in
                    self.dismiss(animated: true, completion: nil)
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
    
    // MARK: function for create a marker pin on map.
    private func createMarker(type: String, titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
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
    
    // Map Navigation Function.
    private func navigationMap(start_lat: String, start_lng: String, end_lat: String, end_lng: String) {
        let origin = "\(start_lat),\(start_lng)"
        let destination = "\(end_lat),\(end_lng)"
 
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getGoogleMapApi(_origin: origin, _destination: destination), method: .get, headers: headers) { response, error in
            
            let json = JSON(response as Any)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.blue
                polyline.map = self.googleMaps
            }
        }
    }
    
}


/*
 * // MARK: - UITextFieldDelegate
 */
extension Driver_RTCS_VC {
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        guard let alertController = presentedViewController as? PCLBlurEffectAlertController else {
            return
        }
        alertController.actions.filter { $0.style != .cancel }.forEach {
            $0.isEnabled = cancel_Textfield?.text?.isEmpty == false
        }
    }
}
