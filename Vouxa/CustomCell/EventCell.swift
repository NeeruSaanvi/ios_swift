//
//  EventCell.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var profileImage : UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var btnPrice: UIButton!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblMalePercent: UILabel!
    @IBOutlet weak var lblFeMalePercent: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var progressView: UIProgressView?
    @IBOutlet  var constraintsProgressBarLeading : NSLayoutConstraint!

    @IBOutlet  var constraintsProgressBarTrailing : NSLayoutConstraint!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        if(DisplayType.iphone5 == Display.typeIsLike || DisplayType.iphone4 == Display.typeIsLike)
        {
            constraintsProgressBarLeading.constant = 1;
            constraintsProgressBarTrailing.constant = 1;
        }
        else
            if(DisplayType.iphone6 == Display.typeIsLike || DisplayType.iphone7 == Display.typeIsLike)
            {
                constraintsProgressBarLeading.constant = 10;
                constraintsProgressBarTrailing.constant = 10;
            }
        else
            {
                constraintsProgressBarLeading.constant = 20;
                constraintsProgressBarTrailing.constant = 20;
        }



    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
