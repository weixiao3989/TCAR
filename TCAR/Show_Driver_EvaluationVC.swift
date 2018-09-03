//
//  Show_Driver_EvaluationVC.swift
//  TCAR
//
//  Created by Chris lin on 2017/11/4.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JSSAlertView

class Show_Driver_EvaluationVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /* IBOutlet Properties */
    @IBOutlet weak var score_Label: UILabel!
    @IBOutlet weak var showScore_ImageView: UIImageView!
    @IBOutlet weak var pastRate_TableView: UITableView!
    
    /* Variables */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    let driver_id = UserDefaults.standard.integer(forKey: "RTCDriver_id")
    var rateArray: Array<String> = []
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Add TableView dataSource and delegate point to this page.
        pastRate_TableView.dataSource = self
        pastRate_TableView.delegate = self

        // Setting NavigationBar Title.
        setupNavigationBarItems()
        
        // Get Drvier Past Rate.
        getDriverPastRate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        rateArray.removeAll()
        super.viewDidDisappear(true)
    }
    
    /*
     # MARK: - Table Delegate Methods #
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rateArray.count > 2 {
            return rateArray.count / 3
        } else {
            return rateArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "driver_rate_cell")
        
        if rateArray.count == 1 {
            cell.textLabel?.text = rateArray[0]
        } else if rateArray.count == 3 {
            cell.textLabel?.text = NSLocalizedString("SDEV_Score", comment: "") + rateArray[indexPath.row] + "   " + NSLocalizedString("SDEV_Delivery_Date", comment: "") + rateArray[indexPath.row + 1]
        } else if rateArray.count == 6 {
            cell.textLabel?.text = NSLocalizedString("SDEV_Score", comment: "") + rateArray[indexPath.row] + "   " + NSLocalizedString("SDEV_Delivery_Date", comment: "") + rateArray[indexPath.row + 2]
        } else {
            cell.textLabel?.text = NSLocalizedString("SDEV_Score", comment: "") + rateArray[indexPath.row] + "   " + NSLocalizedString("SDEV_Delivery_Date", comment: "") + rateArray[indexPath.row + 3]
        }
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showRateDetail(index: indexPath.row)
    }
    
    /*
     # MARK: - Customize Function. #
     */
    
    // Setup NavigaitonBar Title.
    private func setupNavigationBarItems() {
        // Setting NavigationBat Title.
        navigationItem.title = NSLocalizedString("SDEV_Navigation_Title", comment: "")
    }
    
    // Get Driver Rate.
    func getDriverPastRate() {
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
        
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getDriverInfo_URL(_id: String(driver_id)), method: .get, headers: headers) { response, error in
            
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
                var listArray: Array<String> = []
                
                if let ratelist = json["driver"]["rate"]["detail"].array {
                    for rate in ratelist {
                        let score = rate["score"].stringValue
                        let note = rate["note"].stringValue
                        let date = rate["updated_time"].stringValue
                        
                        listArray.append(score)
                        listArray.append(note)
                        listArray.append(date)
                    }
                }
                
                // Judgment rate count to use which case.
                switch json["driver"]["rate"]["count"].intValue {
                case 0:
                    self.rateArray.append(NSLocalizedString("SDEV_AlertView_NoRate_Title", comment: ""))
                    break
                case 1:
                    self.rateArray.append(listArray[0])
                    self.rateArray.append(listArray[2])
                    self.rateArray.append(listArray[1])
                    break
                case 2:
                    // Setting Loop append the value to rateArray. Total: 6 record.
                    // 1-2: score, 3-4: date, 5-6: note , First In First Out.
                    var x = 1, y = 2
                    for i in 1...6 {
                        if i < 3 {
                            self.rateArray.append(listArray[listArray.count - (i * 3)])
                        } else if i < 5 {
                            self.rateArray.append(listArray[listArray.count - x])
                            x += 3
                        } else {
                            self.rateArray.append(listArray[listArray.count - y])
                            y += 3
                        }
                    }
                    break
                default:
                    // Setting Loop append the value to rateArray. Total: 9 record.
                    // 1-3: score, 4-6: date, 7-9: note , First In First Out.
                    var j = 1, k = 2
                    for i in 1...9 {
                        if i < 4 {
                            self.rateArray.append(listArray[listArray.count - (i * 3)])
                        } else if i < 7 {
                            self.rateArray.append(listArray[listArray.count - j])
                            j += 3
                        } else {
                            self.rateArray.append(listArray[listArray.count - k])
                            k += 3
                        }
                    }
                    break
                }
                
                // Round the double to take the first decimal place.
                let average_Score = String(format: "%.1f", json["driver"]["rate"]["score"].doubleValue)
                // Setting Avarage Score.
                self.score_Label.text = average_Score
                // judgment Show Image form Driver Score.
                self.showScore_ImageView.image = TCAR_API.judgmentScore_ShowImage(score: Double(average_Score)!)
                // Reload TableView.
                self.pastRate_TableView.reloadData()
            }
        }
    }
    
    // Select table cell after, Show rate detail.
    func showRateDetail(index: Int) {
        if rateArray.count == 1 {
            JSSAlertView().show(
                self,
                title: self.rateArray[index],
                text: NSLocalizedString("SDEV_AlertView_NoRate_Content", comment: ""),
                buttonText: NSLocalizedString("OK", comment: ""))
        } else if rateArray.count == 3{
            JSSAlertView().show(
                self,
                title: NSLocalizedString("SDEV_GetScore", comment: "") + self.rateArray[index],
                text: NSLocalizedString("SDEV_Delivery_Date", comment: "")
                    + self.rateArray[index + 1]
                    + "\n" + NSLocalizedString("SDEV_Rate", comment: "")
                    + "\n"
                    + self.rateArray[index + 2],
                buttonText: NSLocalizedString("OK", comment: ""))
        } else if rateArray.count == 6 {
            JSSAlertView().show(
                self,
                title: NSLocalizedString("SDEV_GetScore", comment: "") + self.rateArray[index],
                text: NSLocalizedString("SDEV_Delivery_Date", comment: "")
                    + self.rateArray[index + 2]
                    + "\n" + NSLocalizedString("SDEV_Rate", comment: "")
                    + "\n"
                    + self.rateArray[index + 4],
                buttonText: NSLocalizedString("OK", comment: ""))
        } else {
            JSSAlertView().show(
                self,
                title: NSLocalizedString("SDEV_GetScore", comment: "") + self.rateArray[index],
                text: NSLocalizedString("SDEV_Delivery_Date", comment: "")
                    + self.rateArray[index + 3]
                    + "\n" + NSLocalizedString("SDEV_Rate", comment: "")
                    + "\n"
                    + self.rateArray[index + 6],
                buttonText: NSLocalizedString("OK", comment: ""))
        }
    }

}
