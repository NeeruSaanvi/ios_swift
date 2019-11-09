//
//  ChatBubble.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 25/12/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

class ChatBubble: UIView {


    // Properties
    var imageViewChat: UIImageView?
    var imageViewBG: UIImageView?
    var text: String?
    var labelChatText: UILabel?

//    let ScreenSize: CGSize
    /**
     Initializes a chat bubble view

     :param: data   ChatBubble Data
     :param: startY origin.y of the chat bubble frame in parent view

     :returns: Chat Bubble
     */
    init(data: ChatBubbleData, startY: CGFloat){

        // 1. Initializing parent view with calculated frame
        super.init(frame: ChatBubble.framePrimary(type: data.type, startY:startY))

        // Making Background color as gray color
        self.backgroundColor = UIColor.clear

        let padding: CGFloat = 10.0

        // 2. Drawing image if any
        if let chatImage = data.image {

            let width: CGFloat = min(chatImage.size.width, self.frame.width - 2 * padding)
            
            let height: CGFloat = chatImage.size.height * (width / chatImage.size.width)



            imageViewChat = UIImageView.init(frame: CGRect.init(x: padding, y: padding, width: width, height: height))
//            imageViewChat = UIImageView(frame: CGRectMake(padding, padding, width, height))
            imageViewChat?.image = chatImage
            imageViewChat?.layer.cornerRadius = 5.0
            imageViewChat?.layer.masksToBounds = true
            self.addSubview(imageViewChat!)
        }

        // 3. Going to add Text if any
        if data.text != nil {
            // frame calculation
            let startX = padding
            var startY:CGFloat = 5.0
            if imageViewChat != nil {
                startY += imageViewChat!.frame.maxY
            }


            labelChatText = UILabel.init(frame: CGRect.init(x: startX, y: startY, width: self.frame.width - 2 * startX , height: 5))

//            labelChatText = UILabel(frame: CGRectMake(startX, startY, self.frame.width - 2 * startX , 5))

            labelChatText?.textAlignment = data.type == .Mine ? .right : .left
            labelChatText?.font = UIFont.init(name: "Roboto-Regular", size: 15)
            //UIFont.systemFont(ofSize: 14)
            labelChatText?.numberOfLines = 0 // Making it multiline
            labelChatText?.text = data.text
            labelChatText?.sizeToFit() // Getting fullsize of it
            self.addSubview(labelChatText!)
        }
        // 4. Calculation of new width and height of the chat bubble view
        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        if imageViewChat != nil {
            // Height calculation of the parent view depending upon the image view and text label
            viewWidth = max(imageViewChat!.frame.maxX, labelChatText!.frame.maxX) + padding
            viewHeight = max(imageViewChat!.frame.maxY, labelChatText!.frame.maxY) + padding

        } else {
            viewHeight = labelChatText!.frame.maxY + padding/2
            viewWidth = labelChatText!.frame.width + labelChatText!.frame.minX + padding
        }

        // 5. Adding new width and height of the chat bubble frame

        self.frame = CGRect.init(x: self.frame.minX, y: self.frame.minY, width: viewWidth, height: viewHeight)
//        self.frame = CGRectMake(self.frame.minX, self.frame.minY, viewWidth, viewHeight)



        // 6. Adding the resizable image view to give it bubble like shape
        let bubbleImageFileName = data.type == .Mine ? "rightSideChatBG" : "LeftChat"
        imageViewBG = UIImageView(frame:CGRect.init(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height) )

        if data.type == .Mine {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 22, 17, 20))
        }
        self.addSubview(imageViewBG!)
        self.sendSubview(toBack: imageViewBG!)


        // Frame recalculation for filling up the bubble with background bubble image
        let repsotionXFactor:CGFloat = data.type == .Mine ? 0.0 : -8.0
        let bgImageNewX = imageViewBG!.frame.minX + repsotionXFactor
        let bgImageNewWidth =  imageViewBG!.frame.width + CGFloat(12.0)
        let bgImageNewHeight =  imageViewBG!.frame.height + CGFloat(6.0)
        imageViewBG?.frame = CGRect.init(x: bgImageNewX, y: 0.0, width: bgImageNewWidth, height: bgImageNewHeight)
//        CGRectMake(bgImageNewX, 0.0, bgImageNewWidth, bgImageNewHeight)


        // Keepping a minimum distance from the edge of the screen
        var newStartX:CGFloat = 0.0
        if data.type == .Mine {
            // Need to maintain the minimum right side padding from the right edge of the screen
            let extraWidthToConsider = imageViewBG!.frame.width
            newStartX = ScreenSize.SCREEN_WIDTH - extraWidthToConsider

//            if(data.profileImgFlag == true)
//            {
//                newStartX = -imageViewBG!.frame.minX + 3.0 + 50
//            }
//            else{
//                newStartX = -imageViewBG!.frame.minX + 3.0
//            }


        } else {
            // Need to maintain the minimum left side padding from the left edge of the screen

            if(data.profileImgFlag == true)
            {
            newStartX = -imageViewBG!.frame.minX + 3.0 + 50
            }
            else{
                newStartX = -imageViewBG!.frame.minX + 3.0
            }
        }


        self.frame = CGRect.init(x: newStartX, y: self.frame.minY, width: frame.width, height: frame.height)

//        self.frame = CGRectMake(newStartX, CGRectGetMinY(self.frame), frame.width, frame.height)



    }

    // 6. View persistance support
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }



    //MARK: - FRAME CALCULATION
    class func framePrimary(type:BubbleDataType, startY: CGFloat) -> CGRect{
        let paddingFactor: CGFloat = 0.02
        let sidePadding = ScreenSize.SCREEN_WIDTH * paddingFactor
        let maxWidth = ScreenSize.SCREEN_WIDTH * 0.65 // We are cosidering 65% of the screen width as the Maximum with of a single bubble
        let startX: CGFloat = type == .Mine ? ( ScreenSize.SCREEN_WIDTH * (CGFloat(1.0) - paddingFactor) - maxWidth) : sidePadding


        return CGRect.init(x: startX, y: startY, width: maxWidth, height: 5)

        //        return CGRectMake(startX, startY, maxWidth, 5) // 5 is the primary height before drawing starts
    }


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


