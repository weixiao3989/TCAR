//
//  AlertController.swift
//  TCAR
//
//  Created by Chris on 2018/1/21.
//  Copyright © 2018年 MUST. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    /*
     * One Button Normal AlertView.
     * @parameter: 1. title , 2. message, 3. alertTitle, 4. ViewController.
     */
    static func OB_showNormalAlert(title: String, message: String, alertTitle: String ,in viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertTitle, style: .cancel))
        viewController.present(alert, animated: true)
    }
    
    /*
     * One Button Comfirm AlertView.
     * @parameter: 1. title , 2. message, 3. alertTitle, 4. ViewController, 5. Confirm.
     */
    static func OB_showConfirmAlert(title: String, message: String, alertTitle: String ,in viewController: UIViewController,
                            confirm: ((UIAlertAction)->Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertTitle, style: .default, handler: confirm))
        viewController.present(alert, animated: true)
    }
    
    /*
     * Two Button Comfirm AlertView.
     * @parameter: 1. title , 2. message, 3. okTitle, 4. cancelTitle, 5. ViewController, 6. Confirm.
     */
    static func TB_showConfirmAlert(title: String?, message: String?, actionTitles: [String?], in viewController: UIViewController, actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
