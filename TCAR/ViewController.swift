//
//  ViewController.swift
//  TCAR
//
//  Created by Chris on 2017/7/9.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var first_img: UIImageView!
    
    /* Variable */
    var member_type: String = ""
    var notice_enter: Int = 0
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // For All RealTimeCallCar Judgment back to root page.
        // default is true.
        UserDefaults.standard.set(true, forKey: "PRTCVC_root_switch")
        UserDefaults.standard.set(true, forKey: "DRTCVC_root_switch")
        UserDefaults.standard.synchronize()
        
        // Get Who am I infomation.
        askWhoamIAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        first_img.image = UIImage(named: "first_img.png")
        
        self.notice_enter = UserDefaults.standard.integer(forKey: "Enter_Type")
        print("Notice Enter is : \(String(self.notice_enter))")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 , execute: {
            switch self.member_type {
            case "users":
                if (self.notice_enter == 1) {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Passenger_RTCS_VC")
                    self.show(vc!, sender: self)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PassengerNC")
                    self.show(vc!, sender: self)
                }
                break
            case "drivers":
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DriverNC")
                self.show(vc!, sender: self)
                break
            case "none":
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SigninVC")
                self.show(vc!, sender: self)
                break
            default:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SigninVC")
                self.show(vc!, sender: self)
                break
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.member_type = "none"
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    // MARK - API: WhoamI , Method: GET.
    func askWhoamIAPI () {
        // If User Device not have network.
        if currentReachabilityStatus == .notReachable {
            // Display Alert message.
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_NoNetwork", comment: ""),
                message: NSLocalizedString("NoNetwork", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
        }
        
        if let sessionID = UserDefaults.standard.string(forKey: "userSessionID") {
            
            print("sessionID : \(String(describing: sessionID))")
            
            let headers = TCAR_API.getHeader_HasSession()
            
            AccessAPIs.sendRequest_noParameters(url: TCAR_API.getWhoamiURL(), method: .get, headers: headers) {
                response, error in
                
                let json = JSON(response as Any)
                
                guard json["error_code"].intValue == 0 else {
                    // If session has problem.
                    self.member_type = "none"
                    return
                }
                self.member_type = json["member"]["member_type"].stringValue
            }
        } else {
            print("It is not have Session !!")
            self.member_type = "none"
        }
    }

}

