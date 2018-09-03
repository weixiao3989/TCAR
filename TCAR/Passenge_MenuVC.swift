//
//  Menu1VC.swift
//  TCAR
//
//  Created by Chris lin on 2017/7/30.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class Passenger_MenuVC: UIViewController, CLLocationManagerDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var aboutMeBarItem: UIBarButtonItem!
    
    /* Variable */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    let userSex = UserDefaults.standard.integer(forKey: "userSex")
    var locationManager: CLLocationManager!
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = UserDefaults.standard.string(forKey: "userName"){
            switch userSex {
            case 0:
                setupNavigationBarItems(Name: userName, Sex: NSLocalizedString("MV_Lady", comment: ""))
                break
            case 1:
                setupNavigationBarItems(Name: userName, Sex: NSLocalizedString("MV_Mister", comment: ""))
                break
            default:
                break
            }
        } else {
            setupNavigationBarItems(Name: NSLocalizedString("MV_Title_Fail", comment: ""), Sex: "")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let appSetting = URL(string: UIApplicationOpenSettingsURLString)
        
        // Check whether User has enabled the positioning function.
        if(CLLocationManager.authorizationStatus() != .denied) {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startMonitoringSignificantLocationChanges()
        } else {
            UIAlertController.TB_showConfirmAlert(
                title: NSLocalizedString("MV_LS_NotSetting", comment: ""),
                message: "",
                actionTitles: [NSLocalizedString("MV_GotoSetting_LS", comment: ""), NSLocalizedString("Cancel", comment: "")],
                in: self, actions: [{action_setting in
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(appSetting!, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(appSetting!)
                        }
                    }, {action_cancel in }])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     # MARK: - IBAction Methods. #
     */
    
    // MARK - API: Logout , Method: GET.
    @IBAction func logoutButton(_ sender: Any) {
        // If User Device not have network.
        if currentReachabilityStatus == .notReachable {
            // Display Alert message.
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_NoNetwork", comment: ""),
                message: NSLocalizedString("NoNetwork", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
        }
        let headers = TCAR_API.getHeader_HasSession()
        
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getSignoutURL(), method: .get, headers: headers) {
            response, error in
            
            let json = JSON(response as Any)
            guard json["error_code"].intValue == 0 else {
                // Login is failure.
                DispatchQueue.main.async {
                    // RemoveAll User data.
                    UserDefaults.standard.removeObject(forKey: "userSessionID")
                    UserDefaults.standard.removeObject(forKey: "userID")
                    UserDefaults.standard.removeObject(forKey: "driverID")
                    UserDefaults.standard.removeObject(forKey: "userName")
                    UserDefaults.standard.removeObject(forKey: "userSex")
                    UserDefaults.standard.synchronize()
                    
                    UIAlertController.OB_showNormalAlert(
                        title: NSLocalizedString("LogoutFail", comment: ""),
                        message: json["error_message"].stringValue,
                        alertTitle: NSLocalizedString("Cancel", comment: ""),
                        in: self)
                }
                return
            }
            
            // RemoveAll User data.
            UserDefaults.standard.removeObject(forKey: "userSessionID")
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "driverID")
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "userSex")
            UserDefaults.standard.synchronize()
            
            UIAlertController.OB_showConfirmAlert(
                title: NSLocalizedString("LogoutSF", comment: ""),
                message: json["error_message"].stringValue,
                alertTitle: NSLocalizedString("OK", comment: ""),
                in: self) { (_) in
                    self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    /* NavigationBar Setting */
    private func setupNavigationBarItems(Name: String, Sex: String) {
        // Setting NavigationBar Title.
        navigationItem.title = "\(NSLocalizedString("Welcome", comment: "")) \(Name) \(Sex)"
        
        // Setting Navigation Back Item.
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("MV_Back", comment: "")
        navigationItem.backBarButtonItem = backItem
        
        // Setting Navigation Right Bar Item.
        guard userSex == 1 else {
            aboutMeBarItem.image = UIImage(named: "icon_woman_passenger.png")
            return
        }
    }
    
}
