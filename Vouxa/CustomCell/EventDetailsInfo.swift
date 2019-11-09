//
//  EventDetailsInfo.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/6/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

class EventDetailsInfo: UITableViewCell {

    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var imgClock: UIImageView!
    @IBOutlet weak var btnChatAndPrice: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var constratentClockImageHeight: NSLayoutConstraint!
     @IBOutlet weak var constratentAddressLabelTrailing: NSLayoutConstraint!

    @IBOutlet weak var constratentLbl1Trialing: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
