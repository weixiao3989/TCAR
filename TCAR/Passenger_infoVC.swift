//
//  Passenger_infoVC.swift
//  TCAR
//
//  Created by Chris lin on 2018/01/26.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit
import SwiftyJSON

class Passenger_infoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var name_Label: UILabel!
    @IBOutlet weak var score_Label: UILabel!
    @IBOutlet weak var level_Label: UILabel!
    @IBOutlet weak var evaluationsNumber_Label: UILabel!
    @IBOutlet weak var exp_Label: UILabel!
    
    /* Variable */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    let user_id = UserDefaults.standard.string(forKey: "userID")

    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set Target to ImageView.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(tapGestureRecognizer)
        
        // Get User Information.
        getUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     # MARK: - ImagePickerController Delegate Methods #
     */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
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
                self.imgView.image = selectedImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    private func getUserInfo() {
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
        
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getUserInfo_URL(_id: self.user_id!), method: .get, headers: headers) { response, error in
            
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
            self.name_Label.text = json["member"]["name"].stringValue
            let score = json["user"]["rate"]["score"].doubleValue
            let count = json["user"]["rate"]["count"].stringValue
            
            if count.isEmpty {
                self.score_Label.text = NSLocalizedString("PAMV_NoRate_Score_Title", comment: "")
                self.level_Label.text = NSLocalizedString("PAMV_NoRate_Level_Title", comment: "")
                self.evaluationsNumber_Label.text = NSLocalizedString("PAMV_NoRate_Evaluation_Title", comment: "")
                self.exp_Label.text = NSLocalizedString("PAMV_NoRate_Exp_Title", comment: "")
            } else {
                self.evaluationsNumber_Label.text = count
                TCAR_API.judgmentScore(score: score, count: count, score_Label: self.score_Label, level_Label: self.level_Label, exp_Label: self.exp_Label)
            }
            
            DispatchQueue.main.async {
                // Get User Avatar.
                AccessAPIs.getAvatar(url: avatar_url) {
                    data, error in
                    
                    if let image = data {
                        self.imgView.image = image
                    } else {
                        self.imgView.image = UIImage(named: "No_Avatar.png")
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
