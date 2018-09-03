//
//  Network_Access.swift
//  TCAR
//
//  Created by Chris on 2018/1/20.
//  Copyright © 2018年 MUST. All rights reserved.
//

import Alamofire
import AlamofireImage

class AccessAPIs {
    
    static fileprivate let queue = DispatchQueue(label: "requests.queue", qos: .utility)
    static fileprivate let mainQueue = DispatchQueue.main
    
    /*
     * Get API Response JSON Data.
     */
    
    fileprivate class func make(request: DataRequest, closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        request.responseJSON(queue: AccessAPIs.queue) { response in
            switch response.result {
            case .failure(let error):
                AccessAPIs.mainQueue.async {
                    closure(nil, error)
                }
            case .success(let data):
                AccessAPIs.mainQueue.async {
                    closure((data as? [String: Any]) ?? [:], nil)
                }
            }
        }
    }
    
    class func sendRequest_hasParameters(url: String, method: HTTPMethod, headers: HTTPHeaders, parameters: [String : Any], closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        
        let request = Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding(options: []), headers: headers).validate().responseJSON {
            response in
            switch response.result {
            case .success:
                print("Access url : \(url) is Successful")
            case .failure(let error):
                print(error)
            }
            
            // Only Signin need Save Session.
            if (url == TCAR_API.getSigninURL()) {
                // Cookies - Session ID.
                let url = URL(string: TCAR_API.APIBaseURL)!
                let cstorage = HTTPCookieStorage.shared
                if let cookies = cstorage.cookies(for: url) {
                    for cookie:HTTPCookie in cookies {
                        print("name：\(cookie.name)", "value：\(cookie.value)")
                        // Write session ID to the local data, for WhoamI API;
                        UserDefaults.standard.removeObject(forKey: "userSessionID")
                        UserDefaults.standard.set(cookie.value, forKey: "userSessionID")
                        UserDefaults.standard.synchronize()
                    }
                }
            }
        }
        AccessAPIs.make(request: request) { json, error in
            closure(json, error)
        }
    }
    
    class func sendRequest_noParameters(url: String, method: HTTPMethod, headers: HTTPHeaders, closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        
        let request = Alamofire.request(url, method: method, encoding: JSONEncoding(options: []), headers: headers).validate().responseJSON {
            response in
            switch response.result {
            case .success:
                print("Access url : \(url) is Successful")
            case .failure(let error):
                print(error)
            }
        }
        AccessAPIs.make(request: request) { json, error in
            closure(json, error)
        }
    }
    
    /*
     * Get and Set Avatar API Response Image Data.
     */
    
    fileprivate class func makeImage(request: DataRequest, closure: @escaping (_ img: Image?, _ error: Error?)->()) {
        request.responseImage { response in
            switch response.result {
            case .failure(let error):
                AccessAPIs.mainQueue.async {
                    closure(nil, error)
                }
            case .success(let data):
                AccessAPIs.mainQueue.async {
                    closure(data, nil)
                }
            }
        }
    }
    
    class func getAvatar(url: String, closure: @escaping (_ img: Image?, _ error: Error?)->()) {
        let request = Alamofire.request(url)
        AccessAPIs.makeImage(request: request) { image, error in
            closure (image, error)
        }
    }
    
    class func setAvatar(image: UIImage, closure: @escaping (_ json: Any?, _ error: Error?)->()) {
        
        let headers = TCAR_API.getHeader_HasSession()
        let URL = try! URLRequest(url: TCAR_API.getAvatarURL(), method: .post, headers: headers)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(UIImageJPEGRepresentation(image, 1.0)!, withName: "avatar", fileName: "image.png", mimeType: "image/png")
        }, with: URL, encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Access url : \(URL) is Successful")
                    closure (response.result.value, nil)
                }
                
            case .failure(let encodingError):
                print("Errot to upload photo, Response is : \(encodingError)")
                closure (nil, encodingError)
            }
        })
        
    }
    
}
