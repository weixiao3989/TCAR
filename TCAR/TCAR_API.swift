//
//  TCAR_API.swift
//  TCAR
//
//  Created by Chris on 2018/1/16.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit
import Alamofire

class TCAR_API {
    
    static let APIBaseURL: String = "http://tcar.3-omg.com/tcar/"
    static let APITaskURL: String = "http://tcar.3-omg.com/tcar/taxi_task/"
    static let APIKey: String = "bJ0DcJfQnDJoDd59q124"
    
    /*
     * Get Header.
     */
    
    static func getHeader_NoSession() -> HTTPHeaders {
        let header: HTTPHeaders = [
            "API-Key": TCAR_API.APIKey,
            "Content-Type": "Application/json"
        ]
        return header
    }
    
    static func getHeader_HasSession() -> HTTPHeaders {
        if let sessionID = UserDefaults.standard.string(forKey: "userSessionID") {
            let header: HTTPHeaders = [
                "API-Key": TCAR_API.APIKey,
                "Content-Type": "Application/json",
                "Cookie": "PHPSESSID=" + sessionID
            ]
            return header
        } else {
            let header: HTTPHeaders = [
                "API-Key": TCAR_API.APIKey,
                "Content-Type": "Application/json"
            ]
            return header
        }
    }
 
    /*
     * Use BaseURL.
     */
    
    // Get Signup URL.
    static func getSignupURL() -> String {
        let _signupurl: String = self.APIBaseURL + "signup/"
        return _signupurl
    }
    
    // Get Signin URL.
    static func getSigninURL() -> String {
        let _signinurl: String = self.APIBaseURL + "signin/"
        return _signinurl
    }

    // Get WhoamI URL.
    static func getWhoamiURL() -> String {
        let _whoamiurl: String = self.APIBaseURL + "whoami/"
        return _whoamiurl
    }
    
    // Get Upload Avatar URL.
    static func getAvatarURL() -> String {
        let _avatarurl: String = self.APIBaseURL + "upload_avatar/"
        return _avatarurl
    }
    
    // Get Signout URL.
    static func getSignoutURL() -> String {
        let _signouturl: String = self.APIBaseURL + "signout/"
        return _signouturl
    }
    
    /*
     * Use TaskURL.
     */
    
    // Get RealTimeCallCar All List URL.
    static func getRTCCALURL() -> String {
        let _RTCCalllisturl: String = self.APITaskURL + "list.php?type=NOW"
        return _RTCCalllisturl
    }
    
    // Get RealTimeCallCar Status is ESTABLISH URL.
    static func getRTCC_status_ESTABLISH_URL() -> String {
        let _ESTABLISHurl: String = self.APITaskURL + "list.php?type=NOW&status=ESTABLISH"
        return _ESTABLISHurl
    }
    
    // Get RealTimeCallCar Status is DRIVER_CANCEL URL.
    static func getRTCC_status_DRIVER_CANCEL_URL() -> String {
        let _DRIVER_CANCELurl: String = self.APITaskURL + "list.php?type=NOW&status=DRIVER_CANCEL"
        return _DRIVER_CANCELurl
    }
    
    // Get RealTimeCallCar Status is FINISH URL.
    static func getRTCC_status_FINISH_URL() -> String {
        let _FINISHurl: String = self.APITaskURL + "list.php?type=NOW&status=FINISH"
        return _FINISHurl
    }
    
    // Get RealTimeCallCar Add URL.
    static func getRTCC_Add_URL() -> String {
        let _addurl: String = self.APITaskURL + "add.php?type=NOW"
        return _addurl
    }
    
    // Get Reply URL.
    static func getReplyURL() -> String {
        let _replyurl: String = self.APITaskURL + "reply.php"
        return _replyurl
    }
    
    // Get Rate URL.
    static func getRateURL() -> String {
        let _rateurl: String = self.APITaskURL + "rate.php"
        return _rateurl
    }
    
    /*
     * Get Information URL.
     */
    
    // Get Someone Order List information URL.
    static func getListInfo_URL(_id: String) -> String {
        let _listinfourl: String = self.APITaskURL + "listinfo.php?id=" + _id
        return _listinfourl
    }
    
    // Get Someone User Information URL.
    static func getUserInfo_URL(_id: String) -> String {
        let _userinfourl: String = self.APIBaseURL + "user/info/?id=" + _id
        return _userinfourl
    }
    
    // Get Someone Driver Information URL.
    static func getDriverInfo_URL(_id: String) -> String {
        let _driverinfourl: String = self.APIBaseURL + "driver/info/?id=" + _id
        return _driverinfourl
    }
    
    // Get Someone Member Information URL.
    static func getMemberInfo_URL(_id: String) -> String {
        let _memberinfourl: String = self.APIBaseURL + "member/info/?id=" + _id
        return _memberinfourl
    }
    
    /*
     * Other.
     */
    
    // Get Google Map Directions API url.
    static func getGoogleMapApi(_origin: String, _destination: String) -> String {
        let _url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(_origin)&destination=\(_destination)&key=AIzaSyBbdXIm73cKvHIM01Kx1UeFY5ZYT4zpWb4"
        return _url
    }
    
    // Judgment Score, For Show image.
    static func judgmentScore_ShowImage(score: Double) -> UIImage {
        var imgView: UIImage?
        
        switch score {
        case 0..<0.5:
            imgView = UIImage(named: "TCAR_RateScore_0.jpg")
            return imgView!
        case 0.5..<1.0:
            imgView = UIImage(named: "TCAR_RateScore_0-5.jpg")
            return imgView!
        case 1.0..<1.5:
            imgView = UIImage(named: "TCAR_RateScore_1-0.jpg")
            return imgView!
        case 1.5..<2:
            imgView = UIImage(named: "TCAR_RateScore_1-5.jpg")
            return imgView!
        case 2..<2.5:
            imgView = UIImage(named: "TCAR_RateScore_2.jpg")
            return imgView!
        case 2.5..<3:
            imgView = UIImage(named: "TCAR_RateScore_2-5.jpg")
            return imgView!
        case 3..<3.5:
            imgView = UIImage(named: "TCAR_RateScore_3.jpg")
            return imgView!
        case 3.5..<4:
            imgView = UIImage(named: "TCAR_RateScore_3-5.jpg")
            return imgView!
        case 4..<4.5:
            imgView = UIImage(named: "TCAR_RateScore_4.jpg")
            return imgView!
        case 4.5..<4.8:
            imgView = UIImage(named: "TCAR_RateScore_4-5.jpg")
            return imgView!
        case 4.8..<5.1:
            imgView = UIImage(named: "TCAR_RateScore_5.jpg")
            return imgView!
        default:
            imgView = UIImage(named: "TCAR_RateScore_0.jpg")
            return imgView!
        }
    }
    
    // Judgment Score For Show Level and Exp.
    static func judgmentScore(score: Double, count: String, score_Label: UILabel, level_Label: UILabel, exp_Label: UILabel)
    {
        score_Label.text = String(format: "%.1f", score)
        
        switch score * Double(count)! {
        case 0..<10.0:
            let gap = 10.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_CopperII", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 10.0..<20.0:
            let gap = 20.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_CopperI", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 20.0..<30.0:
            let gap = 30.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_SilverII", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 30.0..<40.0:
            let gap = 40.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_SilverI", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 40.0..<50.0:
            let gap = 50.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_GoldII", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 50.0..<60.0:
            let gap = 60.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_GoldI", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 60.0..<70.0:
            let gap = 70.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_PlatinumII", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 70.0..<80.0:
            let gap = 80.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_PlatinumI", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 80.0..<90.0:
            let gap = 90.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_Diamond", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 90.0..<100.0:
            let gap = 100.0 - score * Double(count)!
            level_Label.text = NSLocalizedString("PAMV_Class_Monarch", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_Gap_Title" , comment: "") + String(format: "%.1f", gap) + "%"
            break
        case 100...99999999999999:
            level_Label.text = NSLocalizedString("PAMV_Class_Elite", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_EXP_MAX_Title" , comment: "")
            break
        default:
            level_Label.text = NSLocalizedString("PAMV_Class_Elite", comment: "")
            exp_Label.text = NSLocalizedString("PAMV_EXP_MAX_Title" , comment: "")
            break
        }
    }
    
}
