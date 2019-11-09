//
//  GroupChatTableViewCell.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 20/12/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

class GroupChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imgLeft : UIImageView!
    @IBOutlet weak var imgRight : UIImageView!
    @IBOutlet weak var lblLeft : UILabel!
    @IBOutlet weak var lblRight : UILabel!
    @IBOutlet weak var lblName : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
