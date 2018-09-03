//
//  Driver_ScoreVC.swift
//  TCAR
//
//  Created by Chris on 2018/1/2.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Driver_ScoreVC: UIViewController, JNStarReteViewDelegate {

    /* IBOutlet Properties */
    @IBOutlet weak var messageData_TextField: UITextField!
    @IBOutlet weak var img_View: UIImageView!
    
    /* Variables */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    let order_id = UserDefaults.standard.string(forKey: "Order_id_For_Driver")
    let bounds: CGRect = UIScreen.main.bounds
    var ScoreValue: Float = 3.0
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Judgment current Device , Initialization StarView.
        // >= 768 is iPad. else is iPhone.
        if (bounds.width >= 768) {
            initStarView(x: bounds.width/5.5, y: bounds.height/9.3, width: bounds.width/1.5, height: bounds.height/17)
        } else {
            initStarView(x: bounds.width/9, y: bounds.height/6, width: bounds.width/1.25, height: bounds.height/13)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     # MARK: - JNStarRate Delegate Methods #
     */
    func starRate(view starRateView: JNStarRateView, score: Float) {
        self.ScoreValue = score
    }
    
    /*
     # MARK: - IBAction Methods. #
     */
    
    @IBAction func cancel_ButtonItem(_ sender: Any) {
        // Delete Order id.
        UserDefaults.standard.removeObject(forKey: "Order_id_For_Driver")
        UserDefaults.standard.synchronize()
        // Dismiss twice.
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send_ButtonItem(_ sender: Any) {
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
        
        let headers = TCAR_API.getHeader_HasSession()
        let parameters: [String : Any] = [
            "taxi_task_id": self.order_id!,
            "score": self.ScoreValue,
            "note": self.messageData_TextField.text!
        ]
        
        AccessAPIs.sendRequest_hasParameters(url: TCAR_API.getRateURL(), method: .post, headers: headers, parameters: parameters) { response, error in
            
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
            DispatchQueue.main.async {
                // Delete Order id.
                UserDefaults.standard.removeObject(forKey: "Order_id_For_Driver")
                UserDefaults.standard.synchronize()
                
                UIAlertController.OB_showConfirmAlert(
                    title: json["error_message"].stringValue,
                    message: NSLocalizedString("VeryThanksRate", comment: ""),
                    alertTitle: NSLocalizedString("Done", comment: ""),
                    in: self) { (_) in
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    private func initStarView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let starView = JNStarRateView.init(frame: CGRect(x: x, y: y, width: width, height: height), starCount: 5, score: 3.0)
        starView.delegate = self
        starView.allowHalfCompleteStar = true
        self.view.addSubview(starView)
    }

}
