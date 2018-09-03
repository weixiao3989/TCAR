//
//  Driver_RealTimeCallCarTBCCell.swift
//  TCAR
//
//  Created by Chris on 2017/12/29.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit

class Driver_RealTimeCallCarTBCCell: UITableViewCell {
    
    /* IBOutlet Properties */
    @IBOutlet weak var orderID_Label: UILabel!
    @IBOutlet weak var startLocation_Label: UILabel!
    @IBOutlet weak var userName_Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
