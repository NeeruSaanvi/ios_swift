//
//  ServiceClass.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 24/12/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import JSQSystemSoundPlayer
@objc protocol ServiceClassDelegate {


    @objc optional func groupChatMessageRecive(message: QBChatMessage, dialogeId: String)
    @objc optional func singleChatMessageRecive(message: QBChatMessage)

    @objc optional func getChatMessage(messages: [QBChatMessage])

    //    @objc optional func getDialogs(messages: [QBChatDialog])



}


class ServiceClass: NSObject, QBChatDelegate {

    var currentUser : QBUUser!

    var dialogCurrent: QBChatDialog!

    var deletgate: ServiceClassDelegate! = nil

    var privacyListArray : QBPrivacyList!

//    var timer: Timer!
    var timer = Timer()

    static let sharedInstance = ServiceClass()



    //    class var sharedInstance: ServiceClass {
    //
    //        struct Static {
    //            static let instance = ServiceClass()
    //        }
    //        return Static.instance
    //    }

    func login(userLogin: String, password: String, completion:((_ response: QBResponse?, _ success: Bool) -> Void)?)
    {
        QBRequest.logIn(withUserLogin: userLogin, password: password, successBlock: { (response, user) in

            ServiceClass.sharedInstance.currentUser = user

            QBChat.instance().addDelegate(self)

            //            let user = QBUUser()
            //            user.ID = 56
            //            user.password = "chatUser1pass"

            self.getDialogs()

            self.chatConnect()

            self.startConnectedTime()
            //            QBChat.instance().retrievePrivacyList(withName: "public")



            //            QBChat.instance().connect(with: user!) { (error) -> Void in
            //
            completion?(response, true)
            //            }

            //            QBChat.delegates(self)



        }) { (response) in

            print("\( response.status)")

            if(response.status == QBResponseStatusCode.unAuthorized)
            {
                let user = QBUUser()

                let dicUser : NSDictionary = UtilityClass().getUserDefault(key: "userinfo") as! NSDictionary


                user.login = userLogin
                user.password = password

                let arr = (dicUser.value(forKey: "email") as! String) .components(separatedBy: "@")


                if(arr.count>1)
                {
                    user.email = (arr[0] as String) + "_" + (dicUser.value(forKey: "id") as! String) + "@" + (arr[1] as String)
                }

                self.signUp(user: user, completion: { (response, success) in
                    if(success)
                    {
                        self.login(userLogin: userLogin, password: password, completion: { (respose, success) in

                            if(success)
                            {
                                completion?(response, true)
                            }
                            else
                            {
                                completion?(response, false)
                            }

                        })
                    }
                    else
                    {
                        completion?(response, false)
                    }
                })
            }
            else
            {
                completion?(response, false)
            }
        }
    }


    func signUp(user: QBUUser, completion:((_ response: QBResponse?, _ success: Bool) -> Void)?)
    {

        QBRequest.signUp(user, successBlock: { (response, user) in

            completion?(response, true)
            print("\( response.status)")

        }, errorBlock: { (response) in
            print("\( response.status)")

            completion?(response, true)

        })

    }




    //MARK:
    //MARK: Create a public group

    func createGroup(groupName: String, completion: ((_ response: QBResponse?, _ createdDialog: QBChatDialog?) -> Void)?)
    {

        if(!QBChat.instance().isConnected)
        {
            return
        }

        let chatDialog: QBChatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.publicGroup)

        chatDialog.name = groupName

        let id = NSNumber (value: Int(ServiceClass.sharedInstance.currentUser.id))

        chatDialog.occupantIDs = [id]

        chatDialog.data = ["createdBy": id]

        QBRequest.createDialog(chatDialog, successBlock: {(response: QBResponse?, createdDialog: QBChatDialog?) in
            completion?(response, createdDialog)
//            SVProgressHUD.showSuccess(withStatus: "STR_DIALOG_CREATED".localized)

        }, errorBlock: {(response: QBResponse!) -> Void  in

            guard let unwrappedResponse = response else {
                print("Error empty response")
                return
            }
            if let error = unwrappedResponse.error {
                print(error.error as Any)

                SVProgressHUD.showError(withStatus: error.error?.localizedDescription)
            }

        })
    }



    func createSingleChat(name: String?, userid: NSNumber, completion: ((_ response: QBResponse?, _ createdDialog: QBChatDialog?) -> Void)?) {

        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized)

        let chatDialog: QBChatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.private)

        chatDialog.occupantIDs = [userid]

        QBRequest.createDialog(chatDialog, successBlock: {(response: QBResponse?, createdDialog: QBChatDialog?) in

            SVProgressHUD.dismiss()
            //             SVProgressHUD.showSuccess(withStatus: "STR_DIALOG_CREATED".localized)
            completion?(response, createdDialog)

        }, errorBlock: {(response: QBResponse!) in

            SVProgressHUD.showError(withStatus: response.error.debugDescription)

            //            completion?(response, createdDialog)

        })


        //        if users.count == 1 {
        // Creating private chat.

        //        QBRequest.create
        //
        //
        //
        //
        //        ServicesManager.instance().chatService.createPrivateChatDialog(withOpponent: user, completion: { (response, chatDialog) in
        //
        //            completion?(response, chatDialog)
        //        })
    }





    func deleteDialog(dialogId: String) {

        QBRequest.deleteDialogs(withIDs: Set(arrayLiteral: dialogId), forAllUsers: true, successBlock: { (response: QBResponse!, deletedObjectsIDs: [String]?, notFoundObjectsIDs: [String]?, wrongPermissionsObjectsIDs: [String]?) -> Void in

        }) { (response: QBResponse!) -> Void in

        }

    }


    @nonobjc func chatUserDisconnect()
    {
        if !(UtilityClass().checkUserDefault(key: "userinfo"))
        {
            return
        }


        if(QBChat.instance().isConnected)
        {
            QBChat.instance().disconnect { (error) -> Void in

                if(error != nil)
                {
                    SVProgressHUD.showError(withStatus: error.debugDescription)
                }
            }


            timer.invalidate()
        }
    }

    @objc func chatConnect()
    {


        if !(UtilityClass().checkUserDefault(key: "userinfo"))
        {
            return
        }


        if(QBChat.instance().isConnected || QBChat.instance().isConnecting)
        {
//            self.timer.invalidate()
            return
        }

        
       // SVProgressHUD.show(withStatus: "Por Favor Espero..")
        let obj = QBUUser()

        let dicUser : NSDictionary = UtilityClass().getUserDefault(key: "userinfo") as! NSDictionary


        let password = dicUser.value(forKey: "facebookid") as! String + "123456"


        obj.password = password
        obj.id = currentUser.id

        QBChat.instance().connect(with: obj) { (error) -> Void in

            if(error != nil)
            {
//                SVProgressHUD.showError(withStatus: error.debugDescription)

//                self.startConnectedTime()
                return
            }
            QBChat.instance().retrievePrivacyList(withName: "public")
//            QBChat.instance().retrievePrivacyListNames()
//            self.timer.invalidate()


           // SVProgressHUD.dismiss()
        }
    }



    func Qblogout() {


        QBRequest.logOut(successBlock: { (response) in

        }) { (response) in

        }
    }

    //MARK:
    //MARK: QBCHAT DELEGATES

    func chatDidAccidentallyDisconnect() {

//        startConnectedTime()
    }

    func chatDidReconnect() {
//        startConnectedTime()
    }

    func chatDidFail(withStreamError error: Error?)
    {
//        startConnectedTime()
    }
    func chatDidNotConnectWithError(_ error: Error?)
    {
//        startConnectedTime()
    }


    //MARK QBChatDelegate

    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {

    }


    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {

        if(message.senderID != currentUser.id)
        {
            if(dialogCurrent != nil && dialogCurrent.id == message.dialogID)
            {
                deletgate.groupChatMessageRecive!(message: message, dialogeId: dialogID)
            }
            else
            {
                QMMessageNotificationManager.showNotification(withTitle: message.customParameters.value(forKey: "name") as! String!, subtitle: message.text, type: QMMessageNotificationType.info)

                getDialogs()
            }

            JSQSystemSoundPlayer.jsq_playMessageReceivedAlert()
        }

    }


    func chatDidSetPrivacyList(withName name: String) {
        QBChat.instance().setDefaultPrivacyListWithName("public")

        QBChat.instance().setActivePrivacyListWithName("public")
    }

    func chatDidNotSetActivePrivacyList(withName name: String, error: Any?) {

    }


    // active delegate
    func chatDidSetActivePrivacyList(withName name: String) {
        //       QBChat.instance().retrievePrivacyList(withName: "public")
    }


    func chatDidNotSetPrivacyList(withName name: String, error: Any?) {

    }


    // privacy list delegate
    func chatDidReceive(_ privacyList: QBPrivacyList) {

        privacyListArray = privacyList
    }


    func chatDidNotReceivePrivacyList(withName name: String, error: Any?) {

    }


    // privacy list name delegate
    func chatDidReceivePrivacyListNames(_ listNames: [String]) {

    }


    func chatDidNotReceivePrivacyListNamesDue(toError error: Any?) {


    }

    // MARK:

    //    func chatDidReceiveMessage(message: QBChatMessage) {
    //
    //        if(message.senderID != currentUser.id)
    //        {
    //
    //            deletgate.singleChatMessageRecive!(message: message)
    //        }
    //
    //    }



    func chatDidReceive(_ message: QBChatMessage)
    {
        if(message.senderID != currentUser.id)
        {
            //            if(deletgate != nil)
            //            {
            if(dialogCurrent != nil &&  dialogCurrent.id == message.dialogID)
            {
                deletgate.singleChatMessageRecive!(message: message)

                self.readMessges(message: message)
            }
            else
            {
                QMMessageNotificationManager.showNotification(withTitle: message.customParameters.value(forKey: "name") as! String!, subtitle: message.text, type: QMMessageNotificationType.info)

                getDialogs()
            }

            JSQSystemSoundPlayer.jsq_playMessageReceivedAlert()
            //            }
        }
    }


    func readMessges(message: QBChatMessage)
    {
        // sends 'read' status back
        if message.markable {
            QBChat.instance().read(message, completion: { (error) -> Void in

            })
        }
    }



    func getDialogs()
    {
        if(ServiceClass.sharedInstance.currentUser == nil)
        {
            return
        }


        getUnreadMessages()

//        DispatchQueue.main.async{
        DialogModal.instance.setDialogsList(messages: ModelManager().getDialogs())
//        }

        //            deletgate.getDialogs!(messages: ModelManager().getDialogs())



        let extendedRequest = ["sort_desc" : "last_message_date_sent" ]

//        let extendedRequest = ["sender_id" : "\(ServiceClass.sharedInstance.currentUser.id)" as String , "occupants_ids": "\(ServiceClass.sharedInstance.currentUser.id)" as String];

        QBRequest.countOfDialogs(withExtendedRequest: extendedRequest, successBlock: { (response, countDiloags) in


            for i in 0...Int(countDiloags)/100
            {
                let resPage = QBResponsePage(limit:100, skip: Int(i) * 100)


                QBRequest.dialogs(for: resPage, extendedRequest: extendedRequest, successBlock: { (response, dialogObjects, dialogsUsersIDS, pages) in
//                    DispatchQueue.main.async{
                    ModelManager().insertOrUpdateIntoDialogTable(dialogObjects: dialogObjects!)

                    

                    DialogModal.instance.setDialogsList(messages: ModelManager().getDialogs())
//                    }
                    //                        self.deletgate.getDialogs!(messages: ModelManager().getDialogs())


                    self.getUnreadMessages()

                }) { (response) in
                    print("\(String(describing: response.error))")
                    SVProgressHUD.showError(withStatus: response.error.debugDescription)
                }
            }

        }) { (response) in

        }

    }


    func getMessges(dialogId: String, count: Int)
    {

//

        if(self.deletgate != nil)
        {
//            DispatchQueue.main.async{
            self.deletgate.getChatMessage!(messages: ModelManager().getChatMessages(dialogId: dialogId, count: count))
//            }

        }

        QBRequest.countOfMessages( forDialogID: dialogId, extendedRequest: nil, successBlock: {(response: QBResponse!, count: UInt) in

//            DispatchQueue.main.async{
            let countLocal = ModelManager().getTotalMessageCount(dialogId: dialogId)

            let countnew = Int(count) - countLocal

            if(countnew > 0)
            {
                for i in 0...Int(countnew)/100
                {
                    let resPage = QBResponsePage(limit:100, skip: Int(i) * 100 + countLocal)


                    QBRequest.messages(withDialogID: dialogId, extendedRequest: nil, for: resPage, successBlock: { (response, messages, pages) in

//                        DispatchQueue.main.async{
                        ModelManager().insertIntoChatTable(dialogObjects: messages!)

                        if(self.deletgate != nil)
                        {
                            self.deletgate.getChatMessage?(messages: messages!)
                        }

                         self.updateDialogAtLocal()
//                        }
                    }, errorBlock: { (respose) in

                    })
                }
            }
            else
            {

            }

          //  }
        }, errorBlock: {(response: QBResponse!) in

        })
            
    }


    func blockUserInPrivateChat(Uid: UInt)
    {
//        privacyListArray = QBPrivacyList(name: "public", items: [])
        
        let item: QBPrivacyItem = QBPrivacyItem(privacyType: QBPrivacyType.userID, userID: Uid, allow: false)!

        if(privacyListArray == nil || privacyListArray.privacyItems.count == 0)
        {
            privacyListArray = QBPrivacyList(name: "public", items: [item])
        }
        else
        {
            var i = 0
            for itemTemp in privacyListArray.privacyItems
            {
                if(itemTemp.privacyType == item.privacyType && itemTemp.userID == item.userID)
                {
                    privacyListArray.privacyItems.remove(at: i)
                    
                    //                    tempArray.add(i)
                }
                else
                {
                    i = i+1
                }
            }
            
            
            privacyListArray.addObject(item)
        
        
        }

        QBChat.instance().setPrivacyList(privacyListArray)
    }
    
    func unblockUserInPrivateChat(Uid: UInt)
    {
        let item: QBPrivacyItem = QBPrivacyItem(privacyType: QBPrivacyType.userID, userID: Uid, allow: true)!
        
        if(privacyListArray == nil || privacyListArray.privacyItems.count == 0)
        {
            privacyListArray = QBPrivacyList(name: "public", items: [item])
        }
        else
        {
            //            let tempArray = NSMutableArray()
            var i = 0
            for itemTemp in privacyListArray.privacyItems
            {
                if(itemTemp.privacyType == item.privacyType && itemTemp.userID == item.userID)
                {
                    privacyListArray.privacyItems.remove(at: i)
                    
                    //                    tempArray.add(i)
                }
                else
                {
                    i = i+1
                }
            }
            
            
            privacyListArray.addObject(item)
        }
        
        
        
        QBChat.instance().setPrivacyList(privacyListArray)
    }
    
    

    func blockUserIntoGroup(userId: UInt)
    {
        
        privacyListArray = QBPrivacyList(name: "public", items: [])
        
        let item: QBPrivacyItem = QBPrivacyItem.init(privacyType: QBPrivacyType.groupUserID, userID: userId, allow: false)!

        item.mutualBlock = true

        if(privacyListArray == nil || privacyListArray.privacyItems.count == 0)
        {
            privacyListArray = QBPrivacyList(name: "public", items: [item])
        }
        else
        {
//            let tempArray = NSMutableArray()
            var i = 0
            for itemTemp in privacyListArray.privacyItems
            {
                if(itemTemp.privacyType == item.privacyType && itemTemp.userID == item.userID)
                {
                    privacyListArray.privacyItems.remove(at: i)
                    
                    //                    tempArray.add(i)
                }
                else
                {
                    i = i+1
                }
            }
            
            
            //            for itemTemp in tempArray
            //            {
            //                //                privacyListArray.privacyItems.re
            //                privacyListArray.privacyItems.remove(at: itemTemp as! Int)
            //            }
            
            
            privacyListArray.addObject(item)
        }
        
        QBChat.instance().setPrivacyList(privacyListArray)
    }
    
    func unblockUserIntoGroup(userId: UInt)
    {
        
        privacyListArray = QBPrivacyList(name: "public", items: [])
        
        let item: QBPrivacyItem = QBPrivacyItem.init(privacyType: QBPrivacyType.groupUserID, userID: userId, allow: true)!
        
        //item.mutualBlock = true
        
        if(privacyListArray == nil || privacyListArray.privacyItems.count == 0)
        {
            privacyListArray = QBPrivacyList(name: "public", items: [item])
        }
        else
        {
            //            let tempArray = NSMutableArray()
            var i = 0
            for itemTemp in privacyListArray.privacyItems
            {
                if(itemTemp.privacyType == item.privacyType && itemTemp.userID == item.userID)
                {
                    privacyListArray.privacyItems.remove(at: i)
                    
                    //                    tempArray.add(i)
                }
                else
                {
                    i = i+1
                }
            }
            
            
            //            for itemTemp in tempArray
            //            {
            //                //                privacyListArray.privacyItems.re
            //                privacyListArray.privacyItems.remove(at: itemTemp as! Int)
            //            }
            
            
            privacyListArray.addObject(item)
        }
        
        QBChat.instance().setPrivacyList(privacyListArray)
    }

    
    
    
    func getUnreadMessages()
    {
//        DispatchQueue.main.async{
        let dialogs =  ModelManager().getDialogs()
        
        //        var trimmedUnreadMessageCount : String
        
        var count = 0
        for dialog in dialogs
        {
            
            if (dialog.unreadMessagesCount > 0) {
                count = count + 1;
            }
        }
        
        
        BadgeClass.instance.setBadgeonTabBar(count: count)
//        }

    }
    
    
    
    func updateDialogAtLocal()
    {
//        DispatchQueue.main.async{
        if(self.dialogCurrent != nil)
        {
            self.dialogCurrent.unreadMessagesCount = 0
        
        
        if(ModelManager().updateDialog(dialog: self.dialogCurrent))
        {
            self.getUnreadMessages()
        }
        }
//        }

    }
    
    
    //    // This code is called at most once
    //    class func getInstance() -> ServiceClass
    //    {
    //        if(sharedInstance.database == nil)
    //        {
    //            sharedInstance.database = FMDatabase(path: Util.getPath("Student.sqlite"))
    //        }
    //        return sharedInstance
    //    }
    //   


    func startConnectedTime()
    {

        //    ServiceClass.sharedInstance.timer = Timer.scheduledTimer(timeInterval: 2, target: ServiceClass.sharedInstance, selector: Selector(ServiceClass.sharedInstance.chatConnect()), userInfo: nil, repeats: true)

        self.timer.invalidate()
        //Selector(("chatConnect()"))

        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.chatConnect), userInfo: nil, repeats: true)
        
    }


    
}

