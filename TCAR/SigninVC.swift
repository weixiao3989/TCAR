//
//  SigninVC.swift
//  TCAR
//
//  Created by Chris on 2017/7/9.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON

class SigninVC: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var accout_text: UITextField!
    @IBOutlet weak var password_text: UITextField!

    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// UI
        // Account Text Field hint.
        accout_text.placeholder = NSLocalizedString("PutAccount", comment: "")
        // The edit Test Fiele has clear Button.
        accout_text.clearButtonMode = .whileEditing
        // Change Keyboard retrun to the Done.
        accout_text.returnKeyType = .done
        
        password_text.placeholder = NSLocalizedString("PutPassword", comment: "")
        password_text.clearButtonMode = .whileEditing
        password_text.returnKeyType = .done
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     # MARK: - IBAction Methods. #
     */
    
    @IBAction func Login_BT(_ sender: Any) {
        sendRequestPostLogin()
    }

    @IBAction func Singup_BT(_ sender: Any) {
        // Singup.
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    // If user clicks the screen to return the focus.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        accout_text.resignFirstResponder()
        password_text.resignFirstResponder()
    }
    
    // UITextField Delegate Function, Push down Keyboard 'done', retrun keyboard.
    func textFieldShouldReturn(_ testField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK - API: Signin , Method: POST.
    func sendRequestPostLogin() {
        let user_acount = accout_text.text
        let user_password = password_text.text
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
        let headers = TCAR_API.getHeader_NoSession()
        
        // If User Device not have network.
        if currentReachabilityStatus == .notReachable {
            // Display Alert message.
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_NoNetwork", comment: ""),
                message: NSLocalizedString("NoNetwork", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            return
        } else if ((user_acount?.isEmpty)! || (user_password?.isEmpty)!) {
            // Check for empty fields.
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_Incomplete", comment: ""),
                message: NSLocalizedString("AccontPasswdNeedCorrect", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            return
        } else {
            let parameters: [String : Any] = [
                "account" : user_acount!,
                "password" : user_password!,
                "device_type" : "iOS",
                "push_token" : deviceToken!
            ]
            
            AccessAPIs.sendRequest_hasParameters(url: TCAR_API.getSigninURL(), method: .post, headers: headers, parameters: parameters) {
                response, error in
                
                let json = JSON(response as Any)
                guard json["error_code"].intValue == 0 else {
                    // Login is failure.
                    DispatchQueue.main.async {
                        UIAlertController.OB_showNormalAlert(
                            title: NSLocalizedString("LoginFail", comment: ""),
                            message: json["error_message"].stringValue,
                            alertTitle: NSLocalizedString("Cancel", comment: ""),
                            in: self)
                    }
                    return
                }
                
                let user_type = json["member"]["member_type"].stringValue
                let user_name = json["member"]["name"].stringValue
                let user_sex = json["member"]["sex"].intValue
                // Login is successful.
                DispatchQueue.main.async {
                    // Judgment User type.
                    switch user_type {
                    case "users" :
                        // Write User Name and Sex to the local data, for MenuVC Title.
                        let user_id = json["user"]["id"].stringValue
                        UserDefaults.standard.set(user_id, forKey: "userID")
                        UserDefaults.standard.set(user_name, forKey: "userName")
                        UserDefaults.standard.set(user_sex, forKey: "userSex")
                        UserDefaults.standard.synchronize()
                        // Display alert message with sucessful.
                        UIAlertController.OB_showConfirmAlert(
                            title: NSLocalizedString("LoginSF", comment: ""),
                            message: NSLocalizedString("Welcome", comment: ""),
                            alertTitle: NSLocalizedString("OK", comment: ""),
                            in: self) { (_) in
                                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PassengerNC") {
                                    self.show(vc, sender: self)
                                }
                        }
                        break
                    case "drivers" :
                        // Write User Name and Sex to the local data, for MenuVC Title.
                        let driver_id = json["driver"]["id"].stringValue
                        UserDefaults.standard.set(driver_id, forKey: "driverID")
                        UserDefaults.standard.set(user_name, forKey: "userName")
                        UserDefaults.standard.set(user_sex, forKey: "userSex")
                        UserDefaults.standard.synchronize()
                        // Display alert message with sucessful.
                        UIAlertController.OB_showConfirmAlert(
                            title: NSLocalizedString("LoginSF", comment: ""),
                            message: NSLocalizedString("Welcome", comment: ""),
                            alertTitle: NSLocalizedString("OK", comment: ""),
                            in: self) { (_) in
                                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DriverNC") {
                                    self.show(vc, sender: self)
                                }
                        }
                        break
                    default :
                        break
                    }
                }
            }
        }
    }
    
}
