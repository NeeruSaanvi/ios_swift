//
//  ChatBubbleData.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 25/12/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit // For using UIImage

// 1. Type Enum
/**
 Enum specifing the type

 - Mine:     Chat message is outgoing
 - Opponent: Chat message is incoming
 */
enum BubbleDataType: Int{
    case Mine = 0
    case Opponent
}

/// DataModel for maintaining the message data for a single chat bubble
class ChatBubbleData {

    // 2.Properties
    var text: String?
    var image: UIImage?
    var date: NSDate?
    var type: BubbleDataType
    var profileImgFlag: Bool!

    // 3. Initialization
    init(text: String?,image: UIImage?,date: NSDate? , type:BubbleDataType = .Mine, profileImgFlag: Bool) {
        // Default type is Mine
        self.text = text
        self.image = image
        self.date = date
        self.type = type
        self.profileImgFlag = profileImgFlag
    }
}
