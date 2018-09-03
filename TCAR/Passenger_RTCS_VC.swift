//
//  Passenger_RTCS_VC.swift
//  TCAR
//
//  Created by Chris lin on 2017/11/4.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import MessageUI
import Alamofire
import AlamofireImage
import SwiftyJSON

class Passenger_RTCS_VC: UIViewController, MFMailComposeViewControllerDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var avatar_ImageView: UIImageView!
    @IBOutlet weak var driverName_Label: UILabel!
    @IBOutlet weak var business_NumberLabel: UILabel!
    @IBOutlet weak var car_NumberLabel: UILabel!
    @IBOutlet weak var car_VehicleLabel: UILabel!
    @IBOutlet weak var driverPhone_Button: UIButton!
    @IBOutlet weak var aboutMeBarItem: UIBarButtonItem!
    
    /* Variables */
    let userSex = UserDefaults.standard.integer(forKey: "userSex")
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    let RTCO_id = UserDefaults.standard.integer(forKey: "RTCO_id")
    let driver_id = UserDefaults.standard.integer(forKey: "RTCDriver_id")
    let headers = TCAR_API.getHeader_HasSession()
    var driver_Phone = ""
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch userSex {
        case 0:
            setupNavigationBarItems()
            break
        case 1:
            setupNavigationBarItems()
            break
        default:
            break
        }
        
        // Get Driver Infomation.
        getDriverInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     # MARK: - IBAction Methods. #
     */
    
    @IBAction func finish_Button(_ sender: Any) {
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
        
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getListInfo_URL(_id: String(RTCO_id)), method: .get, headers: headers) {
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
            
            let order_status = json["task"]["status"].stringValue
            if order_status == "FINISH" {
                UIAlertController.TB_showConfirmAlert(
                    title: NSLocalizedString("PRTCS_Thank", comment: ""),
                    message: NSLocalizedString("PRTCS_AskRate", comment: ""),
                    actionTitles: [NSLocalizedString("PRTCS_GoRate", comment: ""), NSLocalizedString("PRTCS_NoRate", comment: "")],
                    in: self,
                    actions: [{action_gorate in
                        // Transfer Passenger_ScoreVC ViewController.
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Passenger_ScoreVC")
                        self.present(vc!, animated: true, completion: nil)
                    }, {action_norate in
                        // Delete RealTimeCallCar Order id.
                        UserDefaults.standard.removeObject(forKey: "RTCO_id")
                        UserDefaults.standard.synchronize()
                        // Dismiss twice.
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }])
            }
        }
    }
    
    @IBAction func callDriver_Button(_ sender: Any) {
        // Telphone Button push down, Cell the Phone.
        let url: NSURL = URL(string: ("TEL://" + driver_Phone))! as NSURL
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    // NavigationBar Setting
    private func setupNavigationBarItems() {
        // Setting Navigation Right Bar Item.
        guard userSex == 1 else {
            aboutMeBarItem.image = UIImage(named: "icon_woman_passenger.png")
            return
        }
    }
    
    // Get Driver Information.
    func getDriverInfo() {
        // URL for Driver Avatar.
        var avatar_url = ""
        
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
        
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getDriverInfo_URL(_id: String(driver_id)), method: .get, headers: headers) {
            response, errot in
            
            let json = JSON(response as Any)
            guard json["error_code"].intValue == 0 else {
                // Login is failure.
                DispatchQueue.main.async {
                    UIAlertController.OB_showNormalAlert(
                        title: NSLocalizedString("Title_Fail", comment: ""),
                        message: json["error_message"].stringValue,
                        alertTitle: NSLocalizedString("Cancel", comment: ""),
                        in: self)
                }
                return
            }
            avatar_url = TCAR_API.APIBaseURL + json["member"]["avatar"].stringValue
            self.driverName_Label.text = json["member"]["name"].stringValue
            self.business_NumberLabel.text = json["driver"]["business_number"].stringValue
            self.car_NumberLabel.text = json["driver"]["car_number"].stringValue
            self.car_VehicleLabel.text = json["driver"]["vehicle"].stringValue
            self.driver_Phone = json["member"]["cellphone"].stringValue
            self.driverPhone_Button.setTitle(NSLocalizedString("PRTCS_Title_CalltheDriver", comment: ""), for: .normal)
            
            // Get Driver Avatar.
            AccessAPIs.getAvatar(url: avatar_url) {
                data, error in

                if let image = data {
                    self.avatar_ImageView.image = image
                } else {
                    UIAlertController.OB_showNormalAlert(
                        title: NSLocalizedString("PRTCS_Title_NotGetAvatar", comment: ""),
                        message: NSLocalizedString("PRTCS_GetAvatarFail", comment: ""),
                        alertTitle: NSLocalizedString("Cancel", comment: ""),
                        in: self)
                }
            }
        }
    }

}
