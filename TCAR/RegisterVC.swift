//
//  RegisterVC.swift
//  TCAR
//
//  Created by Chris on 2017/7/15.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterVC: UIViewController, UITextFieldDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var rg_Account_text: UITextField!
    @IBOutlet weak var rg_Password_text: UITextField!
    @IBOutlet weak var rg_Name_text: UITextField!
    @IBOutlet weak var rg_sex_sc: UISegmentedControl!
    @IBOutlet weak var rg_Verification: UITextField!
    @IBOutlet weak var rg_Phone_text: UITextField!
    
    /* Variables */
    var sex: Int = 0
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load Custom Title.
        setupNavigationBarItems()
        
        // reg_Account Text Field hint.
        rg_Account_text.placeholder = NSLocalizedString("Reg_account", comment: "")
        // Can be deleted at once.
        rg_Account_text.clearButtonMode = .whileEditing
        // Keyboard retrun Change to Done.
        rg_Account_text.returnKeyType = .done
        
        // reg_Password Text Field.
        rg_Password_text.placeholder = NSLocalizedString("Reg_password", comment: "")
        rg_Password_text.clearButtonMode = .whileEditing
        rg_Password_text.returnKeyType = .done
        
        // reg_Name Text Field.
        rg_Name_text.placeholder = NSLocalizedString("Reg_name", comment: "")
        rg_Name_text.returnKeyType = .done
        
        // Verification Text Field.
        rg_Verification.placeholder = NSLocalizedString("Reg_vef", comment: "")
        rg_Verification.returnKeyType = .done
        
        // reg_Phone Text Field.
        rg_Phone_text.placeholder = NSLocalizedString("Reg_phone", comment: "")
        rg_Phone_text.returnKeyType = .done
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     # MARK: - IBAction Methods. #
     */
    
    /* SegmentControl , select sex. */
    @IBAction func select_sex_SGC(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.sex = 0
        case 1:
            self.sex = 1
        default:
            break
        }
    }
    
    /* Trans verification code. */
    @IBAction func trans_Verification_Button(_ sender: Any) {
        print("The Verification code : \(String(describing: rg_Verification.text))")
    }
    
    // MARK - API: Signup , Method: POST.
    @IBAction func enter_register_Button(_ sender: Any) {
        let user_account = rg_Account_text.text
        let user_password = rg_Password_text.text
        let user_name = rg_Name_text.text
        let user_sex = self.sex
        let reg_Verification = rg_Verification.text
        let user_phone = rg_Phone_text.text
        let device_token = UserDefaults.standard.string(forKey: "deviceToken")
        let headers = TCAR_API.getHeader_NoSession()
        
        // Check Phone has only number.
        guard let _ = Int(user_phone!) else {
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_Incomplete", comment: ""),
                message: NSLocalizedString("PhoneOnlyNumber", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            return
        }
        
        // If User Device not have network.
        if currentReachabilityStatus == .notReachable {
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_NoNetwork", comment: ""),
                message: NSLocalizedString("NoNetwork", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            return
        } else if ((user_account?.isEmpty)! || (user_password?.isEmpty)! || (user_name?.isEmpty)! || (reg_Verification?.isEmpty)! || (user_phone?.isEmpty)!)
        {
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Title_Incomplete", comment: ""),
                message: NSLocalizedString("AccontPasswdNeedCorrect", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
            return
        } else {
            let parameters: [String : Any] = [
                "account" : user_account!,
                "password" : user_password!,
                "name" : user_name!,
                "cellphone" : user_phone!,
                "sex" : String(user_sex),
                "device_type" : "iOS",
                "push_token" : device_token!
            ]
            
            AccessAPIs.sendRequest_hasParameters(url: TCAR_API.getSignupURL(), method: .post, headers: headers, parameters: parameters) {
                response, error in
                
                let json = JSON(response as Any)
                
                guard json["error_code"].intValue == 0 else {
                    // Registerred is failure.
                    DispatchQueue.main.async {
                        UIAlertController.OB_showNormalAlert(
                            title: NSLocalizedString("Reg_fail_title", comment: ""),
                            message: json["error_message"].stringValue,
                            alertTitle: NSLocalizedString("Cancel", comment: ""),
                            in: self)
                    }
                    return
                }
                
                // Registered is successful.
                DispatchQueue.main.async {
                    // Display alert message with sucessful.
                    UIAlertController.OB_showConfirmAlert(
                        title: NSLocalizedString("Reg_suc_title", comment: ""),
                        message: json["error_message"].stringValue,
                        alertTitle: NSLocalizedString("Reg_suc_message", comment: ""),
                        in: self) { (_) in
                            self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func returnButtom(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    // UI NavigationBar.
    private func setupNavigationBarItems() {
        navigationItem.title = "TCAR"
    }
    
    // Override tounchesBegan , Let focus return.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rg_Account_text.resignFirstResponder()
        rg_Password_text.resignFirstResponder()
        rg_Name_text.resignFirstResponder()
        rg_Verification.resignFirstResponder()
        rg_Phone_text.resignFirstResponder()
    }
    
    // UITextField Delegate Function, Push down Keyboard 'done', retrun keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
