//
//  Passenger_historyVC.swift
//  TCAR
//
//  Created by Chris lin on 2018/01/26.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit
import SwiftyJSON
import PCLBlurEffectAlert

class Passenger_historyVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var history_TableView: UITableView!
    
    /* Variable */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    let user_id = UserDefaults.standard.string(forKey: "userID")
    let headers = TCAR_API.getHeader_HasSession()
    var table_Count = 0
    // Order ID, For API -> Get Rate information.
    var orderID_Array: Array = [""]
    // Parameters: 0: Service Type, 1: CreateTime, 2: EndTime, 3: StrarLocation, 4: Destination, 5: Person.
    var orderInfo_Array: Array = [""]
    // Parameters: 0: Score, 1: Evaluation.
    var rateInfo_Array: Array = [""]
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        
        // Clear All Array.
        orderID_Array.removeAll()
        orderInfo_Array.removeAll()
        rateInfo_Array.removeAll()
        
        // Get History List (Status is FINISH order list).
        getHistoryList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        orderID_Array.removeAll()
        orderInfo_Array.removeAll()
        rateInfo_Array.removeAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
     # MARK: - Table view Delegate Methods #
     */

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.table_Count == 0 {
            return 1
        } else {
            return self.table_Count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "passenger_HistoryCell", for: indexPath)
        
        if self.table_Count == 0 {
            cell.textLabel?.text = NSLocalizedString("PAMV_NoHistory_Title", comment: "")
        } else {
            cell.textLabel?.text = NSLocalizedString("PAMV_History_Cell_Title", comment: "") + self.orderInfo_Array[(indexPath.row * 6) + 1]
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.table_Count == 0 {
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("PAMV_NoHistory_DialogTxt_Title", comment: ""),
                message: NSLocalizedString("PAMV_NoHistory_DialogTxt_Message", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
        } else {
            let type = NSLocalizedString("PAMV_History_DialogTxt_Title", comment: "") + self.orderInfo_Array[indexPath.row * 6] + "\n"
            let startTime = NSLocalizedString("PAMV_History_DialogTxt_PickupTime", comment: "")
                + self.orderInfo_Array[indexPath.row * 6 + 1] + "\n"
            let endTime = NSLocalizedString("PAMV_History_DialogTxt_UpdatedTime", comment: "")
                + self.orderInfo_Array[indexPath.row * 6 + 2] + "\n"
            let start = NSLocalizedString("PAMV_History_DialogTxt_StartLocation", comment: "")
                + self.orderInfo_Array[indexPath.row * 6 + 3] + "\n"
            let dest = NSLocalizedString("PAMV_History_DialogTxt_Destination", comment: "")
                + self.orderInfo_Array[indexPath.row * 6 + 4] + "\n"
            let person = NSLocalizedString("PAMV_History_DialogTxt_Person", comment: "")
                + self.orderInfo_Array[indexPath.row * 6 + 5] + "\n"
            let score = NSLocalizedString("PAMV_History_DialogTxt_Score", comment: "")
                + self.rateInfo_Array[indexPath.row * 2] + "\n"
            let eva = NSLocalizedString("PAMV_History_DialogTxt_Evaluation", comment: "")
                + self.rateInfo_Array[indexPath.row * 2 + 1]
            
            // Show Order Detail.
            showOrderDetail(type: type, startTime: startTime, endTime: endTime, start: start, dest: dest, person: person, score: score, evalaution: eva)
        }
        
    }
    
    
    /*
     # MARK: - Customize Function. #
     */
    
    private func getHistoryList() {
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
        
        // Get Status is FINISH Order Information.
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getRTCC_status_FINISH_URL(), method: .get, headers: self.headers) { response, error in
            
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
            
            let task_list = json["task"].array
            self.table_Count = task_list!.count
            
            for tasks in task_list! {
                self.orderID_Array.append(tasks["id"].stringValue)
                
                if tasks["type"].stringValue.contains("NOW") {
                    self.orderInfo_Array.append(NSLocalizedString("PAMV_History_DialogTxt_RTCC", comment: ""))
                } else if tasks["type"].stringValue.contains("Resevation") {
                    self.orderID_Array.append(NSLocalizedString("PAMV_History_DialogTxt_RSCC", comment: ""))
                } else {
                    self.orderID_Array.append(NSLocalizedString("PAMV_History_DialogTxt_TCCC", comment: ""))
                }
                
                self.orderInfo_Array.append(tasks["created_time"].stringValue)
                self.orderInfo_Array.append(tasks["updated_time"].stringValue)
                self.orderInfo_Array.append(tasks["pickup_note"].stringValue)
                self.orderInfo_Array.append(tasks["dest_note"].stringValue)
                self.orderInfo_Array.append(tasks["person"].stringValue)
            }
            
            // Get Order content Rate Information.
            for i in self.orderID_Array {
                AccessAPIs.sendRequest_noParameters(url: TCAR_API.getListInfo_URL(_id: i), method: .get, headers: self.headers) { rate_response, error in
                    
                    let rate = JSON(rate_response as Any)
                    guard rate["error_code"].intValue == 0 else {
                        DispatchQueue.main.async {
                            UIAlertController.OB_showNormalAlert(
                                title: NSLocalizedString("Error", comment: ""),
                                message: rate["error_message"].stringValue,
                                alertTitle: NSLocalizedString("Cancel", comment: ""),
                                in: self)
                        }
                        return
                    }
                    
                    if let rate_list = rate["task"]["rate"].array {
                        for rates in rate_list {
                            self.rateInfo_Array.append(rates["score"].stringValue)
                            self.rateInfo_Array.append(rates["note"].stringValue)
                        }
                    } else {
                        self.rateInfo_Array.append(NSLocalizedString("PAMV_History_DialogTxt_NoScore", comment: ""))
                        self.rateInfo_Array.append(NSLocalizedString("PAMV_History_DialogTxt_NoNote", comment: ""))
                    }
                }
            }
            
            // Reload TableView.
            self.history_TableView.reloadData()
        }
    }
    
    /*
     * Select table cell after, Show Order detail.
     * @Parameter :
     * @ 0: ServiceType, 1: StartTime, 2: EndTime, 3: StartLocation, 4: Destination, 5: Person,
     * @ 6: Score, 7: Evalaution.
     */
    private func showOrderDetail(type: String, startTime: String, endTime: String, start: String, dest: String, person: String, score: String, evalaution: String) {
        let alertController = PCLBlurEffectAlertController(title: type,
                                                           message: startTime + endTime + start + dest + person + score + evalaution,
                                                           effect: UIBlurEffect(style: .dark),
                                                           style: .alert)
        alertController.configure(titleColor: .white)
        alertController.configure(messageColor: .white)
        let action_cancel = PCLBlurEffectAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { _ in }
        alertController.addAction(action_cancel)
        alertController.show()
    }
    
}
