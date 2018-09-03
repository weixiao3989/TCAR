//
//  Passenger_favouriteVC.swift
//  TCAR
//
//  Created by Chris lin on 2018/01/26.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit

class Passenger_favouriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /* IBOutlet Properties */
    @IBOutlet weak var favouirte_TableView: UITableView!
    
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
        return 12
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passenger_FavouriteCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "其"
            break
        case 1:
            cell.textLabel?.text = "實"
            break
        case 2:
            cell.textLabel?.text = "我"
            break
        case 3:
            cell.textLabel?.text = "不"
            break
        case 4:
            cell.textLabel?.text = "知"
            break
        case 5:
            cell.textLabel?.text = "道"
            break
        case 6:
            cell.textLabel?.text = "這"
            break
        case 7:
            cell.textLabel?.text = "個"
            break
        case 8:
            cell.textLabel?.text = "要"
            break
        case 9:
            cell.textLabel?.text = "放"
            break
        case 10:
            cell.textLabel?.text = "什"
            break
        case 11:
            cell.textLabel?.text = "麼"
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIAlertController.OB_showNormalAlert(
            title: "點了這個也沒用",
            message: "因為這要放啥我也不知道",
            alertTitle: NSLocalizedString("Cancel", comment: ""),
            in: self)
    }

}
