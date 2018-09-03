//
//  Driver_RealTimeCallCarTBC.swift
//  TCAR
//
//  Created by Chris on 2017/12/29.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PCLBlurEffectAlert

class Driver_RealTimeCallCarTBC: UITableViewController {

    /* Variable */
    let sessionID = UserDefaults.standard.string(forKey: "userSessionID")
    var order_id_array: Array = [""]
    var userName_array: Array = [""]
    var starlocation_array: Array = [""]
    var order_info_array: Array = [""]
    let cellReuseIdentifier = "Drive_RTCCTBC_cell"
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting Title.
        setupNavigationBarItems()
        
        // Initialization RefreshControl.
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshData),
                                       for: .valueChanged)
        self.refreshControl!.attributedTitle = NSAttributedString(string: NSLocalizedString("DRTCV_Refresh_Title", comment: ""))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(true)
        // Clear All list array.
        order_id_array.removeAll()
        userName_array.removeAll()
        starlocation_array.removeAll()
        order_info_array.removeAll()
        
        // Get RealTimeCallCar Order list.
        getRTCCOrderList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(true)
        // Delete Order id & User id.
        UserDefaults.standard.removeObject(forKey: "Order_id_For_Driver")
        UserDefaults.standard.removeObject(forKey: "User_id_For_Driver")
        UserDefaults.standard.synchronize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        // Judgment Diver RealTimeCallCar back to root page.
        if UserDefaults.standard.bool(forKey: "DRTCVC_root_switch") {
            self.navigationController?.popViewController(animated: true)
        } else {
            UserDefaults.standard.set(true, forKey: "DRTCVC_root_switch")
            UserDefaults.standard.synchronize()
        }
    }
    
    /*
     # MARK: - Table view Delegate Methods #
     */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if order_id_array.count < 1 {
            return 1
        } else {
            return order_id_array.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if order_id_array.count < 1 {
            let no_order_cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! Driver_RealTimeCallCarTBCCell
            
            no_order_cell.orderID_Label.text = ""
            no_order_cell.userName_Label.text = NSLocalizedString("DRTCV_Not_Have_NOW_Order_Title", comment: "")
            no_order_cell.startLocation_Label.text = NSLocalizedString("DRTCV_Not_Have_NOW_Order_Message", comment: "")
            return no_order_cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! Driver_RealTimeCallCarTBCCell
            
            cell.orderID_Label.text = self.order_id_array[(order_id_array.count - indexPath.row) - 1]
            cell.startLocation_Label.text = self.starlocation_array[(starlocation_array.count - indexPath.row) - 1]
            cell.userName_Label.text = self.userName_array[(userName_array.count - indexPath.row) - 1]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if order_id_array.count < 1 {
            UIAlertController.OB_showNormalAlert(
                title: NSLocalizedString("DRTCV_Not_Have_NOW_Order_Title", comment: ""),
                message: NSLocalizedString("DRTCV_Not_Have_NOW_Order_Message", comment: ""),
                alertTitle: NSLocalizedString("Cancel", comment: ""),
                in: self)
        } else {
            let user_id = self.order_info_array[self.order_info_array.count - (indexPath.row * 10 + 10)]
            let title = self.userName_array[self.userName_array.count - indexPath.row - 1]
            let startlocation = NSLocalizedString("DRTCV_DialogTxt_StartLocation", comment: "")
                + self.starlocation_array[self.starlocation_array.count - indexPath.row - 1] + "\n"
            let destition = NSLocalizedString("DRTCV_DialogTxt_Destination", comment: "")
                + self.order_info_array[self.order_info_array.count - (indexPath.row * 10 + 5)] + "\n"
            let person = NSLocalizedString("DRTCV_DialogTxt_Person", comment: "") + self.order_info_array[self.order_info_array.count - (indexPath.row * 10 + 4)] + "\n"
            let bigbag = NSLocalizedString("DRTCV_DialogTxt_BigBag", comment: "") + self.order_info_array[self.order_info_array.count - (indexPath.row * 10 + 3)] + "\n"
            let smallbag = NSLocalizedString("DRTCV_DialogTxt_SmallBag", comment: "") + self.order_info_array[self.order_info_array.count - (indexPath.row * 10 + 2)] + "\n"
            let note = NSLocalizedString("DRTCV_DialogTxt_Note", comment: "") + self.order_info_array[self.order_info_array.count - (indexPath.row * 10 + 1)]
            
            // Show Order Detail.
            showOrderDetail(user_id: user_id, order_id: self.order_id_array[self.order_id_array.count - indexPath.row - 1], title: title, start: startlocation, dest: destition, person: person, bb: bigbag, sb: smallbag, note: note)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        UIView.animate(withDuration: 0.7) {
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    /*
     * // MARK: - Customize Function.
     */
    
    // Setup NavigaitonBar Title.
    private func setupNavigationBarItems() {
        navigationItem.title = NSLocalizedString("DRTCV_Order_List", comment: "")
    }
    
    // Refresh Data.
    @objc func refreshData() {
        // Remove All Array Data.
        self.order_id_array.removeAll()
        self.userName_array.removeAll()
        self.starlocation_array.removeAll()
        self.order_info_array.removeAll()
        
        // Get Real Time Call Car Order again.
        getRTCCOrderList()
        
        // Finish Refresh.
        self.refreshControl!.endRefreshing()
    }
    
    // Get RealTimeCallCar Status is ESTABLISH list.
    private func getRTCCOrderList() {
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
        
        AccessAPIs.sendRequest_noParameters(url: TCAR_API.getRTCC_status_ESTABLISH_URL(), method: .get, headers: headers) { response, error in
            
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
            
            if let task_list = json["task"].array {
                for tasks in task_list {
                    let id = tasks["id"].intValue
                    let user = tasks["users_id"]["member"]["name"].stringValue
                    let sex = tasks["users_id"]["member"]["sex"].intValue
                    
                    if sex == 0 {
                        let userName = user + " " + NSLocalizedString("MV_Lady", comment: "")
                        self.userName_array.append(userName)
                    } else {
                        let userName = user + " " + NSLocalizedString("MV_Mister", comment: "")
                        self.userName_array.append(userName)
                    }
                    
                    let user_id = tasks["users_id"]["id"].intValue
                    let pickup_lat = tasks["pickup_lat"].doubleValue
                    let pickup_lng = tasks["pickup_lng"].doubleValue
                    let pickup_note = tasks["pickup_note"].stringValue
                    
                    // Wait Backend modify parameters. #Chris - 180126.
                    // Wait Update Destnation latitude and longitude.
                    // let dest_lat = tasks["dest_lat"].doubleValue
                    // let dest_lng = tasks["dest_lng"].doubleValue
                    let dest_lat = "123.456"
                    let dest_lng = "123.456"
                    let dest_note = tasks["dest_note"].stringValue
                    let person = tasks["person"].intValue
                    let bigbag = tasks["bb"].intValue
                    let smallbag = tasks["sb"].intValue
                    let note = tasks["note"].stringValue
                    
                    self.order_id_array.append(String(id))
                    self.order_info_array.append(String(user_id))
                    self.order_info_array.append(String(pickup_lat))
                    self.order_info_array.append(String(pickup_lng))
                    self.starlocation_array.append(pickup_note)
                    self.order_info_array.append(String(dest_lat))
                    self.order_info_array.append(String(dest_lng))
                    self.order_info_array.append(dest_note)
                    self.order_info_array.append(String(person))
                    self.order_info_array.append(String(bigbag))
                    self.order_info_array.append(String(smallbag))
                    self.order_info_array.append(note)
                }
            }
            
            // Reload TableView.
            self.tableView.reloadData()
        }
    }
    
    /*
     * Select table cell after, Show Order detail.
     * @Parameter :
     * @ 0: UserID, 1: Title, 2: StartLocation, 3: Destination, 4: Person
     * @ 5: BigBag, 6: SmallBag, 7: Note.
     */
    private func showOrderDetail(user_id: String, order_id: String, title: String, start: String, dest: String, person: String, bb: String, sb: String, note: String) {
        let alertController = PCLBlurEffectAlertController(title: title,
                                                           message: start + dest + person + bb + sb + note,
                                                           effect: UIBlurEffect(style: .dark),
                                                           style: .alert)
        alertController.configure(titleColor: .white)
        alertController.configure(messageColor: .white)
        
        let action_CheckRate = PCLBlurEffectAlertAction(title: NSLocalizedString("DRTCV_Check_Passenger_Rate", comment: ""), style: .default)
        { _ in
            // Set RTCVC back root page switch for false.
            UserDefaults.standard.set(false, forKey: "DRTCVC_root_switch")
            UserDefaults.standard.synchronize()
            // Trans to Show Passenger Evaluation VC.
            let SPE_vc = self.storyboard?.instantiateViewController(withIdentifier: "Show_Passenger_EvaluationVC") as! Show_Passenger_EvaluationVC
            SPE_vc.user_id = user_id
            self.show(SPE_vc, sender: self)
        }
        
        let action_StartTask = PCLBlurEffectAlertAction(title: NSLocalizedString("DRTCV_Accept_Order", comment: ""), style: .default)
        { _ in
            DispatchQueue.main.async {
                // Remove All Array Data.
                self.order_id_array.removeAll()
                self.userName_array.removeAll()
                self.starlocation_array.removeAll()
                self.order_info_array.removeAll()
                // Write RealTimeCall Order and User ID to the local data.
                UserDefaults.standard.set(user_id, forKey: "User_id_For_Driver")
                UserDefaults.standard.set(order_id, forKey: "Order_id_For_Driver")
                UserDefaults.standard.synchronize()
                // Transfer WaitDriver ViewController.
                let DRTCSvc = self.storyboard?.instantiateViewController(withIdentifier: "Driver_RTCVC")
                self.present(DRTCSvc!, animated: true, completion: nil)
            }
        }
        
        let action_Dismiss = PCLBlurEffectAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { _ in }
        
        alertController.addAction(action_CheckRate)
        alertController.addAction(action_StartTask)
        alertController.addAction(action_Dismiss)
        alertController.show()
    }

}
