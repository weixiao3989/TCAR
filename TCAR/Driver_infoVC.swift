//
//  Driver_infoVC.swift
//  TCAR
//
//  Created by Chris lin on 2018/01/26.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit
import SwiftyJSON

class Driver_infoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /* IBOutlet Properties */
    @IBOutlet weak var avatar_imgView: UIImageView!
    @IBOutlet weak var driverName_Label: UILabel!
    @IBOutlet weak var score_Label: UILabel!
    @IBOutlet weak var level_Label: UILabel!
    @IBOutlet weak var evaNumber_Label: UILabel!
    @IBOutlet weak var exp_Label: UILabel!
    
    /* Variable */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    let driver_id = UserDefaults.standard.string(forKey: "driverID")
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set Target to ImageView.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        avatar_imgView.isUserInteractionEnabled = true
        avatar_imgView.addGestureRecognizer(tapGestureRecognizer)
        
        // Get User Information.
        getDriverInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     # MARK: - imagePickerController Delegate Methods #
     */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // Get UIImagePickerController Select Document.
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = pickedImage
        }
        
        // Judgment selectedImageFromPicker is Empty? if not, Upload to Server.
        if let selectedImage = selectedImageFromPicker {
            
            AccessAPIs.setAvatar(image: selectedImage) { response, error in
                
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
                self.avatar_imgView.image = selectedImage
            }
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    private func getDriverInfo() {
        // If User Device not have network.
        if currentReachabilityStatus == .notReachable {
            // Display Alert message.
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("NoNetwork", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
        }
        
        let headers = TCAR_API.getHeader_HasSession()
        
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getDriverInfo_URL(_id: self.driver_id!), method: .get, headers: headers) { response, error in
            
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
            
            let avatar_url = TCAR_API.APIBaseURL + json["member"]["avatar"].stringValue
            self.driverName_Label.text = json["member"]["name"].stringValue
            let score = json["driver"]["rate"]["score"].doubleValue
            let count = json["driver"]["rate"]["count"].stringValue
            
            if count.isEmpty {
                self.score_Label.text = NSLocalizedString("DAMV_NoRate_Score_Title", comment: "")
                self.level_Label.text = NSLocalizedString("DAMV_NoRate_Level_Title", comment: "")
                self.evaNumber_Label.text = NSLocalizedString("DAMV_NoRate_Evaluation_Title", comment: "")
                self.exp_Label.text = NSLocalizedString("DAMV_NoRate_Exp_Title", comment: "")
            } else {
                self.evaNumber_Label.text = count
                TCAR_API.judgmentScore(score: score, count: count, score_Label: self.score_Label, level_Label: self.level_Label, exp_Label: self.exp_Label)
            }
            
            DispatchQueue.main.async {
                // Get User Avatar.
                AccessAPIs.getAvatar(url: avatar_url) {
                    data, error in
                    
                    if let image = data {
                        self.avatar_imgView.image = image
                    } else {
                        self.avatar_imgView.image = UIImage(named: "No_Avatar.png")
                    }
                }
            }
        }
    }
    
    // Image Targer Action -> Upload Photo.
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        // Create UIImagePickerController.
        let imagePickerController = UIImagePickerController()
        
        // Setting delegate.
        imagePickerController.delegate = self
        
        // Create UIAlertController , style is actionSheet
        let imagePickerAlertController = UIAlertController(title: NSLocalizedString("Upload_Photo", comment: "" ), message: NSLocalizedString("Select_Upload_Photo", comment: ""), preferredStyle: .actionSheet)
        
        // Create Three UIAlertAction.
        let imageFromLibAction = UIAlertAction(title: NSLocalizedString("Photo_Library", comment: ""), style: .default) { (Void) in
            
            // Judgment Can Load PhotoLibrary.
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (Void) in
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
        
    }
    
}
