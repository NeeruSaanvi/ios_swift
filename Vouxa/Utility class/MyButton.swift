//
//  MyButton.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/14/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

class MyButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    self.layer.cornerRadius = 5.0;
//    self.layer.borderColor = UIColor.redColor.CGColor
//    self.layer.borderWidth = 1.5
//    self.backgroundColor = UIColor.blueColor()
//    self.tintColor = UIColor.whiteColor()
    }
    
    

}
