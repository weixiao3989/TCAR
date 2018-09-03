//
//  Driver_scheduleVC.swift
//  TCAR
//
//  Created by Chris lin on 2018/01/26.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit

class Driver_scheduleVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /* IBOutlet Properties */
    @IBOutlet weak var schedule_TableView: UITableView!
    
    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        return 11
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "driver_ScheduleCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "現"
            break
        case 1:
            cell.textLabel?.text = "在"
            break
        case 2:
            cell.textLabel?.text = "沒"
            break
        case 3:
            cell.textLabel?.text = "有"
            break
        case 4:
            cell.textLabel?.text = "預"
            break
        case 5:
            cell.textLabel?.text = "約"
            break
        case 6:
            cell.textLabel?.text = "包"
            break
        case 7:
            cell.textLabel?.text = "車"
            break
        case 8:
            cell.textLabel?.text = "這"
            break
        case 9:
            cell.textLabel?.text = "件"
            break
        case 10:
            cell.textLabel?.text = "事"
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIAlertController.OB_showNormalAlert(
            title: "點了這個也沒用",
            message: "因為現在還沒實作預約包車的功能...",
            alertTitle: NSLocalizedString("Cancel", comment: ""),
            in: self)
    }
    
}
