//
//  ChatViewController.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 23/02/17.
//  Copyright © 2017 Pinesucceed. All rights reserved.
//

import UIKit
import CoreTelephony
import SafariServices

struct blockUser {
   static var isblock: Bool!
    
}

var messageTimeDateFormatter: DateFormatter {
    struct Static {
        static let instance : DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }

    return Static.instance
}

extension String {
    var length: Int {
        return (self as NSString).length
    }
}

class ChatViewController: QMChatViewController, ServiceClassDelegate, QMChatCellDelegate
{

    let maxCharactersNumber = 1024 // 0 - unlimited


    var dialog: QBChatDialog!
    var willResignActiveBlock: AnyObject?
    var detailedCells: Set<String> = []
//    var chatMessages: [QBChatMessage]?

    var opponentId: UInt!
    var opponentImage: UIImage!
//    var isBlock: Bool!
    let refresher = UIRefreshControl()
    // MARK:
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()


    
        // top layout inset for collectionView
        self.topContentAdditionalInset = self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height;


        // set current user is and name
        //        self.senderID
        self.senderID = ServiceClass.sharedInstance.currentUser.id
        self.senderDisplayName = ServiceClass.sharedInstance.currentUser.fullName
        self.heightForSectionHeader = 40.0

//        self.collectionView
        self.collectionView.frame = CGRect.init(x: 0, y: 64, width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height - 64 - 50)
        

        self.collectionView?.backgroundColor = UIColor (colorLiteralRed: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1)
        self.inputToolbar?.contentView?.backgroundColor = UIColor.white
        self.inputToolbar?.contentView?.textView?.placeHolder = "Mensaje"
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.rightBarButtonItem.setBackgroundImage(UIImage.init(named: "sendChatButton"), for: UIControlState.normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: UIControlState.normal)

        self.inputToolbar.contentView.backgroundColor = UIColor.lightGray

        // set for check url or phone number
        self.enableTextCheckingTypes = NSTextCheckingAllTypes

        // set delegate
        ServiceClass.sharedInstance.deletgate = self

        
        // get chat history
        getChatHistory()

        // set dialog in service call variable
        ServiceClass.sharedInstance.dialogCurrent = dialog


        //set details of user
        setTitleAndBlockStatus()
        // Do any additional setup after loading the view.

        self.tabBarController?.tabBar.isHidden = true

//         self.tabBarItem.accessibilityElementsHidden = true
//        
//        self.collectionView.bounds = CGRect.init(x: 0, y: 50, width: self.refresher.bounds.size.width, height: self.refresher.bounds.size.height)
//        
//        
////        refreshController.bounds = CGRectMake(0, 50, refreshController.bounds.size.width, refreshController.bounds.size.height)
//        


//        self.collectionView!.alwaysBounceVertical = true
//        refresher.tintColor = UIColor.black
//        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
//        self.collectionView!.addSubview(refresher)

        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    // set details
    func setTitleAndBlockStatus()
    {
        if let dialogName = dialog.name {
            self.title = dialogName
        }

        let occupantIDs = dialog.occupantIDs

        for id in occupantIDs!
        {

            if(id != NSNumber(value: ServiceClass.sharedInstance.currentUser.id))
            {
                opponentId = id as! UInt
                let button = UIButton.init(type: .custom)
                button.setBackgroundImage(UIImage.init(named: "profile_pic"), for: UIControlState.normal)
                button.addTarget(self, action:#selector((profileImageClick)), for: UIControlEvents.touchUpInside)
                button.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40) //CGRectMake(0, 0, 30, 30)

                button.layer.cornerRadius = 20

                let barButton = UIBarButtonItem.init(customView: button)
                self.navigationItem.rightBarButtonItem = barButton



                QBRequest.user(withID: UInt(id), successBlock: { (response, userOponion) in

                    do{

                        self.opponentImage = try UIImage.init(data: Data.init(contentsOf: URL.init(string: (string:(userOponion?.customData)!) as! String)!))

                        self.opponentImage = self.opponentImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                        button.layer.masksToBounds = true
                        button.layer.cornerRadius = 20
                        button.setBackgroundImage(self.opponentImage, for: UIControlState.normal)

                    }
                    catch{

                    }


                }, errorBlock: { (response) in

                })

                break
            }
        }


        blockUser.isblock = false
        
        if(ServiceClass.sharedInstance.privacyListArray != nil)
        {
            var i = -1
            for privateUser in ServiceClass.sharedInstance.privacyListArray.privacyItems
            {
                i = i+1

                if(privateUser.userID == opponentId)
                {
                    blockUser.isblock = true
                }
            }
        }
    }

    // profile pic click action
    func profileImageClick()
    {
        let profile : UserProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        
//        profile.isBlock = self.isBlock
        profile.opponentId = opponentId
        profile.profileImage = self.opponentImage
        self.navigationController?.pushViewController(profile, animated: true)
        
        
       /* var message = "¿Está seguro de bloquear?"

        if(self.isBlock == true)
        {
            message = "¿Está seguro de desbloquear?"
        }

        let alert = UIAlertController(title: "alerta", message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))

        //        alert.addAction(UIAlertAction(title: "Sí", style: UIAlertActionStyle.default, handler: nil))

        alert.addAction(UIAlertAction(title: "Sí", style: UIAlertActionStyle.default, handler: { (action) in

            if(self.isBlock == true)
            {
                ServiceClass.sharedInstance.unblockUserInPrivateChat(Uid: self.opponentId)
                self.isBlock = false
            }
            else
            {
                ServiceClass.sharedInstance.blockUserInPrivateChat(Uid: self.opponentId)
                self.isBlock = true
            }
        }))


        DispatchQueue.main.async{
            self.present(alert, animated: true, completion: nil)
        }
        */

    }


    // get chat lits
    func getChatHistory()  {
//        SVProgressHUD.show(withStatus: "por favor espera...")
        DispatchQueue.main.async{
        ServiceClass.sharedInstance.getMessges(dialogId: self.dialog.id!, count: -1)
            }
    }


    //MARK: Service Class

    func singleChatMessageRecive(message: QBChatMessage) {

        DispatchQueue.main.async{

            self.chatDataSource.add(message)

            self.finishReceivingMessage()
//            self.finishSendingMessage(animated: true)
            var chatMessageArray = [QBChatMessage]()

            chatMessageArray.append(message)
            ModelManager().insertIntoChatTable(dialogObjects: chatMessageArray)
            
           

        }
    }


    func getChatMessage(messages: [QBChatMessage]) {

        self.chatDataSource.add(messages)


        DispatchQueue.main.async{

            
            
//            var temparray = messages
            
            
//            temparray.append(self.chatDataSource)
            
//            self.chatDataSource.a
            
//            self.chatDataSource.dele

//        self.chatDataSource.add(messages)
//            self.chatDataSource.add(messages)

            self.finishReceivingMessage()
//             SVProgressHUD.dismiss()
//            self.finishSendingMessage(animated: true)

        }

    }



    // MARK: Action
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: Date!) {

        //        if !self.queueManager().shouldSendMessagesInDialog(withID: self.dialog.id!) {
        //            return
        //        }
        //        self.fireSendStopTypingIfNecessary()


        //            self.view.endEditing(true)

        let message = QBChatMessage()
        message.text = text!
        let params = NSMutableDictionary()
        params["save_to_history"] = true

        params["added_occupant_ids"] = dialog.occupantIDs

        params["name"] = ServiceClass.sharedInstance.currentUser.fullName
        params["avatar"] = ServiceClass.sharedInstance.currentUser.customData

        message.customParameters = params


        message.senderID = ServiceClass.sharedInstance.currentUser.id
        //            message.

        message.readIDs = [(NSNumber(value: ServiceClass.sharedInstance.currentUser.id))]

        message.markable = true
        message.dateSent = Date()

        //            message.dialogID = dialog.id

        self.chatDataSource.add(message)

        self.finishSendingMessage(animated: true)

        sendMessage(message: message)



        //        self.sendMessage(message: message)
    }


    // send message to user
    func sendMessage(message: QBChatMessage) {


        var flag: Bool = false

        dialog.onBlockedMessage = {
            (error) -> Void in

            QMMessageNotificationManager.showNotification(withTitle: "SA_STR_ERROR".localized, subtitle: "Usted está bloqueado por el usuario", type: QMMessageNotificationType.warning)
            flag = true
            print(error!)
        }

        dialog.send(message, completionBlock: { (error) -> Void in

            if error != nil {
                QMMessageNotificationManager.showNotification(withTitle: "SA_STR_ERROR".localized, subtitle: "Error al enviar el mensaje", type: QMMessageNotificationType.warning)
                print(error.debugDescription)
                
            }
            else
            {
                if(flag == false)
                {
                    var chatMessageArray = [QBChatMessage]()
                    chatMessageArray.append(message)
                    ModelManager().insertIntoChatTable(dialogObjects: chatMessageArray)
                }
            }
        })
    }
    
    


    // MARK: Helper
    func canMakeACall() -> Bool {

        var canMakeACall = false

        if (UIApplication.shared.canOpenURL(URL.init(string: "tel://")!)) {

            // Check if iOS Device supports phone calls
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier = networkInfo.subscriberCellularProvider
            if carrier == nil {
                return false
            }
            let mnc = carrier?.mobileNetworkCode
            if mnc?.length == 0 {
                // Device cannot place a call at this time.  SIM might be removed.
            }
            else {
                // iOS Device is capable for making calls
                canMakeACall = true
            }
        }
        else {
            // iOS Device is not capable for making calls
        }

        return canMakeACall
    }



    // MARK: Override

    override func viewClass(forItem item: QBChatMessage) -> AnyClass? {
        // TODO: check and add QMMessageType.AcceptContactRequest, QMMessageType.RejectContactRequest, QMMessageType.ContactRequest

        if  item.isDateDividerMessage {
            return QMChatNotificationCell.self
        }

        if (item.senderID != self.senderID) {

//            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
//
//                return QMChatAttachmentIncomingCell.self
//
//            }
//            else {

                return QMChatIncomingCell.self
//            }

        }
        else {

//            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
//
//                return QMChatAttachmentOutgoingCell.self
//
//            }
//            else {

                return QMChatOutgoingCell.self
//            }
        }
    }

    // MARK: Strings builder

    override func attributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString? {

        guard messageItem.text != nil else {
            return nil
        }

        var textColor = messageItem.senderID == self.senderID ? UIColor.black : UIColor.black
        if messageItem.isDateDividerMessage {
            textColor = UIColor.black
        }

        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 17)

        let attributedString = NSAttributedString(string: messageItem.text!, attributes: attributes)

        return attributedString
    }


    /**
     Creates top label attributed string from QBChatMessage

     - parameter messageItem: QBCHatMessage instance

     - returns: login string, example: @SwiftTestDevUser1
     */
    override func topLabelAttributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString? {

//         guard messageItem.senderID != self.senderID else {
            return nil
//        }
//
//        guard self.dialog.type != QBChatDialogType.private else {
//            return nil
//        }
//
//        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
//        paragrpahStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
//        var attributes = Dictionary<String, AnyObject>()
//        attributes[NSForegroundColorAttributeName] = UIColor(red: 11.0/255.0, green: 96.0/255.0, blue: 255.0/255.0, alpha: 1.0)
//        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 17)
//        attributes[NSParagraphStyleAttributeName] = paragrpahStyle
//
//        var topLabelAttributedString : NSAttributedString?
//
//        if let topLabelText = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: messageItem.senderID)?.login {
//            topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
//        } else { // no user in memory storage
//            topLabelAttributedString = NSAttributedString(string: "@\(messageItem.senderID)", attributes: attributes)
//        }
//
//        return topLabelAttributedString
    }

    /**
     Creates bottom label attributed string from QBChatMessage using self.statusStringFromMessage

     - parameter messageItem: QBChatMessage instance

     - returns: bottom label status string
     */
    override func bottomLabelAttributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString! {

        let textColor = messageItem.senderID == self.senderID ? UIColor.white : UIColor.black

        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byWordWrapping

        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 13)
        attributes[NSParagraphStyleAttributeName] = paragrpahStyle

        let text = messageItem.dateSent != nil ? messageTimeDateFormatter.string(from: messageItem.dateSent!) : ""

//        if messageItem.senderID == self.senderID {
//            text = text + "\n" + self.statusStringFromMessage(message: messageItem)
//        }

        let bottomLabelAttributedString = NSAttributedString(string: text, attributes: attributes)

        return bottomLabelAttributedString
    }

    // MARK: Collection View Datasource

    override func collectionView(_ collectionView: QMChatCollectionView!, dynamicSizeAt indexPath: IndexPath!, maxWidth: CGFloat) -> CGSize {

        var size = CGSize.zero

        guard let message = self.chatDataSource.message(for: indexPath) else {
            return size
        }

        let messageCellClass: AnyClass! = self.viewClass(forItem: message)


        if messageCellClass === QMChatAttachmentIncomingCell.self {

            size = CGSize(width: min(200, maxWidth), height: 200)
        }
        else if messageCellClass === QMChatAttachmentOutgoingCell.self {

            let attributedString = self.bottomLabelAttributedString(forItem: message)

            let bottomLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: min(200, maxWidth), height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
            size = CGSize(width: min(200, maxWidth), height: 200 + ceil(bottomLabelSize.height))
        }
        else if messageCellClass === QMChatNotificationCell.self {

            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }
        else {

            let attributedString = self.attributedString(forItem: message)

            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }

        return size
    }

    override func collectionView(_ collectionView: QMChatCollectionView!, minWidthAt indexPath: IndexPath!) -> CGFloat {

        var size = CGSize.zero

        guard let item = self.chatDataSource.message(for: indexPath) else {
            return 0
        }

        if self.detailedCells.contains(item.id!) {

            let str = self.bottomLabelAttributedString(forItem: item)
            let frameWidth = collectionView.frame.width
            let maxHeight = CGFloat.greatestFiniteMagnitude

            size = TTTAttributedLabel.sizeThatFitsAttributedString(str, withConstraints: CGSize(width:frameWidth - kMessageContainerWidthPadding, height: maxHeight), limitedToNumberOfLines:0)
        }

        if self.dialog.type != QBChatDialogType.private {

            let topLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(self.topLabelAttributedString(forItem: item), withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)

            if topLabelSize.width > size.width {
                size = topLabelSize
            }
        }

        return size.width
    }

    override func collectionView(_ collectionView: QMChatCollectionView!, layoutModelAt indexPath: IndexPath!) -> QMChatCellLayoutModel {

        var layoutModel: QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAt: indexPath)

        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        layoutModel.topLabelHeight = 0.0
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5
        layoutModel.maxWidthMarginSpace = 20.0

        guard let item = self.chatDataSource.message(for: indexPath) else {
            return layoutModel
        }

        let viewClass: AnyClass = self.viewClass(forItem: item)! as AnyClass

        if viewClass === QMChatIncomingCell.self || viewClass === QMChatAttachmentIncomingCell.self {

            if self.dialog.type != QBChatDialogType.private {
                let topAttributedString = self.topLabelAttributedString(forItem: item)
                let size = TTTAttributedLabel.sizeThatFitsAttributedString(topAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:1)
                layoutModel.topLabelHeight = size.height
            }

            layoutModel.spaceBetweenTopLabelAndTextView = 5
        }

        var size = CGSize.zero

        if self.detailedCells.contains(item.id!) {

            let bottomAttributedString = self.bottomLabelAttributedString(forItem: item)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
        }

        layoutModel.bottomLabelHeight = floor(size.height)


        return layoutModel
    }

    override func collectionView(_ collectionView: QMChatCollectionView!, configureCell cell: UICollectionViewCell!, for indexPath: IndexPath!) {

        super.collectionView(collectionView, configureCell: cell, for: indexPath)

        // subscribing to cell delegate
        let chatCell = cell as! QMChatCell

        chatCell.delegate = self

//        let message = self.chatDataSource.message(for: indexPath)
//
//        if let attachmentCell = cell as? QMChatAttachmentCell {
//
//            if attachmentCell is QMChatAttachmentIncomingCell {
//                chatCell.containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
//            }
//            else if attachmentCell is QMChatAttachmentOutgoingCell {
//                chatCell.containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
//            }
//
////            if let attachment = message?.attachments?.first {
//
////                var keysToRemove: [String] = []
////
////                let enumerator = self.attachmentCellsMap.keyEnumerator()
////
////                while let existingAttachmentID = enumerator.nextObject() as? String {
////                    let cachedCell = self.attachmentCellsMap.object(forKey: existingAttachmentID as AnyObject?)
////                    if cachedCell === cell {
////                        keysToRemove.append(existingAttachmentID)
////                    }
////                }
////
////                for key in keysToRemove {
////                    self.attachmentCellsMap.removeObject(forKey: key as AnyObject?)
////                }
////
////                self.attachmentCellsMap.setObject(attachmentCell, forKey: attachment.id as AnyObject?)
////
////                attachmentCell.attachmentID = attachment.id
////
////                // Getting image from chat attachment cache.
////
////                ServicesManager.instance().chatService.chatAttachmentService.image(forAttachmentMessage: message!, completion: { [weak self] (error, image) in
////
////                    guard attachmentCell.attachmentID == attachment.id else {
////                        return
////                    }
////
////                    self?.attachmentCellsMap.removeObject(forKey: attachment.id as AnyObject?)
////
////                    guard error == nil else {
////                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
////                        print("Error downloading image from server: \(error).localizedDescription")
////                        return
////                    }
////
////                    if image == nil {
////                        print("Image is nil")
////                    }
////
////                    attachmentCell.setAttachmentImage(image)
////                    cell.updateConstraints()
////                })
//            }

//        }
//        else
        if cell is QMChatIncomingCell || cell is QMChatAttachmentIncomingCell {

            chatCell.containerView?.bgColor = UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 1.0)
//            chatCell.layer.borderWidth = 1
        }
        else if cell is QMChatOutgoingCell {

//            let status: QMMessageStatus = self.queueManager().status(for: message!)

//            switch status {
//            case .sent:
                chatCell.containerView?.bgColor = UIColor(red: 234.0/255.0, green: 209.0/255.0, blue: 241.0/255.0, alpha: 1.0)
//            case .sending:
//                chatCell.containerView?.bgColor = UIColor(red: 166.3/255.0, green: 171.5/255.0, blue: 171.8/255.0, alpha: 1.0)
//            case .notSent:
//                chatCell.containerView?.bgColor = UIColor(red: 254.6/255.0, green: 30.3/255.0, blue: 12.5/255.0, alpha: 1.0)
//            }

        }
//        else if cell is QMChatAttachmentOutgoingCell {
//            chatCell.containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
//        }
        else if cell is QMChatNotificationCell {
            cell.isUserInteractionEnabled = false
            chatCell.containerView?.bgColor = self.collectionView?.backgroundColor
        }
    }

    /**
     Allows to copy text from QMChatIncomingCell and QMChatOutgoingCell
     */
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {

        guard let item = self.chatDataSource.message(for: indexPath) else {
            return false
        }

        let viewClass: AnyClass = self.viewClass(forItem: item)! as AnyClass

        if  viewClass === QMChatNotificationCell.self ||
            viewClass === QMChatContactRequestCell.self {
            return false
        }

        return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
    }



    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

        let item = self.chatDataSource.message(for: indexPath)

//        if (item?.isMediaMessage())! {
//            ServicesManager.instance().chatService.chatAttachmentService.localImage(forAttachmentMessage: item!, completion: { (error: Error?,image: UIImage?) in
//
//                guard error == nil else {
//                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
//                    return
//                }
//
//                if image != nil {
//                    guard let imageData = UIImageJPEGRepresentation(image!, 1) else { return }
//
//                    let pasteboard = UIPasteboard.general
//
//                    pasteboard.setValue(imageData, forPasteboardType:kUTTypeJPEG as String)
//                }
//            })
//        }
//        else {
            UIPasteboard.general.string = item?.text
//        }
    }



//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let lastSection = self.collectionView!.numberOfSections - 1
//
//        if (indexPath.section == lastSection && indexPath.item == (self.collectionView?.numberOfItems(inSection: lastSection))! - 1) {
//            // the very first message
//            // load more if exists
//            // Getting earlier messages for chat dialog identifier.
//
//            guard let dialogID = self.dialog.id else {
//                print("DialogID is nil")
//                return super.collectionView(collectionView, cellForItemAt: indexPath)
//            }
//
//            ServicesManager.instance().chatService.loadEarlierMessages(withChatDialogID: dialogID).continue({ [weak self] (task) -> Any? in
//
//                guard let strongSelf = self else { return nil }
//
//                if (task.result?.count ?? 0 > 0) {
//
//                    strongSelf.chatDataSource.add(task.result as! [QBChatMessage]!)
//                }
//
//                return nil
//            })
//        }
//
//        // marking message as read if needed
//        if let message = self.chatDataSource.message(for: indexPath) {
////            self.sendReadStatusForMessage(message: message)
//        }
//
//        return super.collectionView(collectionView, cellForItemAt
//            : indexPath)
//    }

    // MARK: QMChatCellDelegate

    /**
     Removes size from cache for item to allow cell expand and show read/delivered IDS or unexpand cell
     */
    func chatCellDidTapContainer(_ cell: QMChatCell!) {
        let indexPath = self.collectionView?.indexPath(for: cell)

        guard let currentMessage = self.chatDataSource.message(for: indexPath) else {
            return
        }

//        let messageStatus: QMMessageStatus = self.queueManager().status(for: currentMessage)
//
//        if messageStatus == .notSent {
//            self.handleNotSentMessage(currentMessage, forCell:cell)
//            return
//        }

        if self.detailedCells.contains(currentMessage.id!) {
            self.detailedCells.remove(currentMessage.id!)
        } else {
            self.detailedCells.insert(currentMessage.id!)
        }

        self.collectionView?.collectionViewLayout.removeSizeFromCache(forItemID: currentMessage.id)
        self.collectionView?.performBatchUpdates(nil, completion: nil)

    }

//    func chatcell
    func chatCell(_ cell: QMChatCell!, didTapAtPosition position: CGPoint) {}

    func chatCell(_ cell: QMChatCell!, didPerformAction action: Selector!, withSender sender: Any!) {}

    func chatCell(_ cell: QMChatCell!, didTapOn result: NSTextCheckingResult) {

        switch result.resultType {

        case NSTextCheckingResult.CheckingType.link:

            let strUrl : String = (result.url?.absoluteString)!

            let hasPrefix = strUrl.lowercased().hasPrefix("https://") || strUrl.lowercased().hasPrefix("http://")

            if #available(iOS 9.0, *) {
                if hasPrefix {

                    let controller = SFSafariViewController(url: URL(string: strUrl)!)
                    self.present(controller, animated: true, completion: nil)

                    break
                }

            }
            // Fallback on earlier versions

            if UIApplication.shared.canOpenURL(URL(string: strUrl)!) {

                UIApplication.shared.openURL(URL(string: strUrl)!)
            }

            break

        case NSTextCheckingResult.CheckingType.phoneNumber:

            if !self.canMakeACall() {

                SVProgressHUD.showInfo(withStatus: "Tu dispositivo no puede hacer una llamada telefónica")
//                SVProgressHUD.showInfo(withStatus: "Your Device can't make a phone call".localized, maskType: .none)
                break
            }

            let urlString = String(format: "tel:%@",result.phoneNumber!)
            let url = URL(string: urlString)

            self.view.endEditing(true)

            let alertController = UIAlertController(title: "",
                                                    message: result.phoneNumber,
                                                    preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (action) in

            }

            alertController.addAction(cancelAction)

            let openAction = UIAlertAction(title: "SA_STR_CALL".localized, style: .destructive) { (action) in
                UIApplication.shared.openURL(url!)
            }
            alertController.addAction(openAction)

            self.present(alertController, animated: true) {
            }

            break

        default:
            break
        }
    }

    func chatCellDidTapAvatar(_ cell: QMChatCell!) {
    }

//    // MARK: QMDeferredQueueManager
//
//    func deferredQueueManager(_ queueManager: QMDeferredQueueManager, didAddMessageLocally addedMessage: QBChatMessage) {
//
//        if addedMessage.dialogID == self.dialog.id {
//            self.chatDataSource.add(addedMessage)
//        }
//    }
//
//    func deferredQueueManager(_ queueManager: QMDeferredQueueManager, didUpdateMessageLocally addedMessage: QBChatMessage) {
//
//        if addedMessage.dialogID == self.dialog.id {
//            self.chatDataSource.update(addedMessage)
//        }
//    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false;
        ServiceClass.sharedInstance.deletgate = nil
        ServiceClass.sharedInstance.dialogCurrent = nil
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func loadData()
    {
        //code to execute during refresher

         DispatchQueue.main.async{

            self.chatDataSource.add( ModelManager.getInstance().getChatMessages(dialogId: self.dialog.id!, count: self.chatDataSource.messagesCount()))


            self.finishReceivingMessage()
        }




//
//        DispatchQueue.main.async{
//            var indexPaths: [AnyObject] = []
//            for i in 0..<tempArray.count
//            {
//
//                self.chatDataSource
//                self.arrayChat.insert(tempArray[i], at: i)
//
//            }





        stopRefresher()         //Call this to stop refresher
    }
    
    func stopRefresher()
    {
        refresher.endRefreshing()
    }
    
    
}
