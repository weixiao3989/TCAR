//
//  Wait_DriverVC.swift
//  TCAR
//
//  Created by Chris lin on 2017/11/4.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PCLBlurEffectAlert

extension Notification.Name {
    static let start_WDVC_AnimationView = Notification.Name(rawValue: "start_WDVC_AnimationView")
}

class Wait_DriverVC: UIViewController {
    
    /* IBOutlet Properties */
    @IBOutlet weak var animationView_Main: UIView!
    @IBOutlet weak var animationView_Point1: UIView!
    @IBOutlet weak var animationView_Point2: UIView!
    @IBOutlet weak var animationView_Point3: UIView!
    @IBOutlet weak var tips_label: UILabel!
    
    /* Variables */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    let RTCO_id = UserDefaults.standard.integer(forKey: "RTCO_id")
    let bounds: CGRect = UIScreen.main.bounds
    let headers = TCAR_API.getHeader_HasSession()
    
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
        
        tips_label.text = NSLocalizedString("WDVC_Tips_Label", comment: "")

        // Setting all animation View background transparent.
        self.animationView_Main.backgroundColor = UIColor(white: 1, alpha: 0)
        self.animationView_Point1.backgroundColor = UIColor(white: 1, alpha: 0)
        self.animationView_Point2.backgroundColor = UIColor(white: 1, alpha: 0)
        self.animationView_Point3.backgroundColor = UIColor(white: 1, alpha: 0)
        
        // First start this page, call NotificationCenter #selector: setupAnimation function.
        NotificationCenter.default.addObserver(self, selector: #selector(setupAnimation(notification:)), name: .start_WDVC_AnimationView, object: nil)
        NotificationCenter.default.post(name: Notification.Name("start_WDVC_AnimationView"), object: nil)
        
        // This page start go to Background, reset Animation frame view.
        NotificationCenter.default.addObserver(self, selector:
            #selector(resetAnimation(notification:)), name:
            Notification.Name.UIApplicationWillResignActive, object: nil)

        // From Background back to Foregroung action this notification.
        NotificationCenter.default.addObserver(self, selector:
            #selector(setupAnimation(notification:)), name:
            Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
     # MARK: - IBAction Methods. #
     */
    
    @IBAction func refreshButton(_ sender: Any) {
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
                        title: NSLocalizedString("Error", comment: ""),
                        message: json["error_message"].stringValue,
                        alertTitle: NSLocalizedString("Cancel", comment: ""),
                        in: self)
                }
                return
            }
            
            let order_status = json["task"]["status"].stringValue
            let driver_id = json["task"]["drivers_id"].intValue
            
            switch order_status {
            case "ESTABLISH" :
                print("Order: \(String(self.RTCO_id)), this status is : \(order_status)")
                break
            case "DRIVER_ACCEPT" :
                DispatchQueue.main.async {
                    // Write RealTimeCall Driver ID to the local data.
                    UserDefaults.standard.set(driver_id, forKey: "RTCDriver_id")
                    UserDefaults.standard.synchronize()
                    // Trans to the Passenger_RTCS_NC.
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Passenger_RTCS_NC")
                    self.show(vc!, sender: self)
                }
                break
            case "DRIVER_CANCEL" :
                print("Order: \(String(self.RTCO_id)), this status is : \(order_status)")
                break
            default :
                print("Order: \(String(self.RTCO_id)), this status is : \(order_status)")
                break
            }
        }
    }
    
    
    @IBAction func userCancelOrder_Button(_ sender: Any) {
        let alertController = PCLBlurEffectAlertController(
            title: NSLocalizedString("WDVC_Cancel_Order_Title", comment: ""),
            message: NSLocalizedString("WDVC_CancelOrder_Message", comment: ""),
            style: .alert)
        alertController.addTextField { (textField: UITextField!) in
            textField.placeholder = NSLocalizedString("WDVC_CancelOrder_Placeholder", comment: "")
            self.cancel_Textfield = textField
        }
        alertController.configure(textFieldsViewBackgroundColor: UIColor.white.withAlphaComponent(0.1))
        alertController.configure(textFieldBorderColor: .black)
        alertController.configure(buttonDisableTextColor: [.default: .lightGray, .destructive: .lightGray])
        let sendAction = PCLBlurEffectAlertAction(title: NSLocalizedString("WDVC_CancelOrder_Send", comment: ""), style: .destructive) { (action) in
            
            let textField = self.cancel_Textfield?.text
            DispatchQueue.main.async {
                let parameters: [String : Any] = [
                    "taxi_task_id": self.RTCO_id,
                    "reply": "USER_CANCEL",
                    "cancel_reason": textField!
                ]
                
                AccessAPIs.sendRequest_hasParameters(url: TCAR_API.getReplyURL(), method: .post, headers: self.headers, parameters: parameters) {
                    response, error in
                    
                    let json = JSON(response as Any)
                    guard json["error_code"].intValue == 0 else {
                        DispatchQueue.main.async {
                            UIAlertController.OB_showNormalAlert(
                                title: NSLocalizedString("Error", comment: ""),
                                message: json["error_message"].stringValue,
                                alertTitle: NSLocalizedString("Cancel", comment: ""),
                                in: self)
                        }
                        return
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        let cancelAction = PCLBlurEffectAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in }
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        alertController.show()
    }

    /*
     # MARK: - Customize Function. #
     */
    
    // Reset animation frame location.
    @objc func resetAnimation(notification: Notification) {
        self.animationView_Main.frame.origin.x = 0
        self.animationView_Point1.frame.origin.y = 0
        self.animationView_Point2.frame.origin.y = 0
        self.animationView_Point3.frame.origin.y = 0
    }
    
    // Draw animation function.
    @objc func setupAnimation(notification: Notification) {
        let width_taxi = self.bounds.width / 2.5
        let height_taxi = self.bounds.height / 5
        let width_point = self.bounds.width / 20
        let height_point = self.bounds.height / 20
        
        // Taxi Animation View.
        UIView.animate(withDuration: 1, animations: {
            let frame = CGRect(x:16, y:height_taxi / 2.5, width: width_taxi, height: height_taxi)
            let backgroundImage = UIImageView(frame: frame)
            backgroundImage.image = UIImage(named: "Animation_Taxi.png")
            self.animationView_Main.insertSubview(backgroundImage, at: 0)
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
                self.animationView_Main.frame.origin.x -= 10
            })
        }
        
        // Point 1 Animation View.
        UIView.animate(withDuration: 1, animations: {
            let frame = CGRect(x:16, y:height_point / 2, width: width_point, height: height_point)
            let backgroundImage = UIImageView(frame: frame)
            backgroundImage.image = UIImage(named: "Animation_Point.png")
            self.animationView_Point1.insertSubview(backgroundImage, at: 0)
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
                self.animationView_Point1.frame.origin.y -= 20
            })
        }
        
        // Point 2 Animation View.
        UIView.animate(withDuration: 1, animations: {
            let frame = CGRect(x:16, y:height_point / 3, width: width_point, height: height_point)
            let backgroundImage = UIImageView(frame: frame)
            backgroundImage.image = UIImage(named: "Animation_Point.png")
            self.animationView_Point2.insertSubview(backgroundImage, at: 0)
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
                self.animationView_Point2.frame.origin.y -= 20
            })
        }
        
        // Point 3 Animation View.
        UIView.animate(withDuration: 1, animations: {
            let frame = CGRect(x:16, y:height_point / 4, width: width_point, height: height_point)
            let backgroundImage = UIImageView(frame: frame)
            backgroundImage.image = UIImage(named: "Animation_Point.png")
            self.animationView_Point3.insertSubview(backgroundImage, at: 0)
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0.45, options: [.autoreverse, .repeat], animations: {
                self.animationView_Point3.frame.origin.y -= 20
            })
        }
    }

}


/*
 * // MARK: - UITextFieldDelegate
 */
extension Wait_DriverVC {
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        guard let alertController = presentedViewController as? PCLBlurEffectAlertController else {
            return
        }
        alertController.actions.filter { $0.style != .cancel }.forEach {
            $0.isEnabled = cancel_Textfield?.text?.isEmpty == false
        }
    }
}
