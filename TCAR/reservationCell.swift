//
//  reservationCell.swift
//  TCAR
//
//  Created by david lin on 2017/10/20.
//  Copyright © 2017年 MUST. All rights reserved.
//

import UIKit

class reservationCell: UITableViewCell {
    
    /* IBOutlet Properties */
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var evaluationUILavel: UILabel!
    @IBOutlet weak var nameUILabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
