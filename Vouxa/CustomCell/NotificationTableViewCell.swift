//
//  NotificationTableViewCell.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/9/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnAccept: UIButton?
    @IBOutlet weak var btnDecline: UIButton?
    @IBOutlet weak var imgProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
