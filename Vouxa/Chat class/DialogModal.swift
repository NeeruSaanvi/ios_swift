//
//  DialogModal.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 08/01/17.
//  Copyright © 2017 Pinesucceed. All rights reserved.
//

import UIKit

@objc protocol DialogModalDelegate {
    @objc optional func getDialogs(messages: [QBChatDialog])
    @objc optional func getPrivateDialogs(messages: [QBChatDialog])
}


class DialogModal: NSObject {

    static let instance = DialogModal()
    var delegate: DialogModalDelegate! = nil

    func setDialogsList(messages: [QBChatDialog])
    {
        var arraySingleChat = [QBChatDialog]()
        var arrayGroupChat = [QBChatDialog]()

        for dialog in messages
        {
            if(dialog.type == QBChatDialogType.private)
            {
                arraySingleChat.append(dialog)
            }
            else{
                if(dialog.lastMessageText != nil)
                {
                arrayGroupChat.append(dialog)
                }
            }
        }


        if(delegate != nil)
        {
            delegate!.getDialogs!(messages: arrayGroupChat)
            delegate!.getPrivateDialogs!(messages: arraySingleChat)
        }
    }



}
