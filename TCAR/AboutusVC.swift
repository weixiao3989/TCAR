//
//  AboutusVC.swift
//  TCAR
//
//  Created by Chris on 2017/9/25.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit
import MessageUI

class AboutusVC: UIViewController, MFMailComposeViewControllerDelegate {

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
     # MARK: - IBAction Methods. #
     */
    
    @IBAction func cellPhoneButton(_ sender: Any) {
        // Telphone Button push down, Cell the Phone.
        let url: NSURL = URL(string: "TEL://0932313520")! as NSURL
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    @IBAction func returnButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
