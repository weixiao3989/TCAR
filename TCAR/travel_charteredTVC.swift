//
//  travel_charteredTVC.swift
//  TCAR
//
//  Created by david lin on 2017/10/11.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit

class travel_charteredTVC: UITableViewController {
    
    /* Variable */
    private var driver_name = ["111","222","333"]
    private var driver_map:[String]!
    private var driver_evaluation:[Int]!

    /*
     # MARK: - View lifecycle. #
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return driver_name.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "travel_charteredCell", for: indexPath) as! travel_charteredCell

        cell.nameUILabel.text = driver_name[indexPath.row]
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = driver_name[indexPath.row]
        print(name)
    }
    
}
