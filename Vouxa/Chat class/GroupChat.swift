//
//  GroupChat.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 2/27/17.
//  Copyright © 2017 Pinesucceed. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class GroupChat: JSQMessagesViewController, ServiceClassDelegate, JSQMessagesComposerTextViewPasteDelegate {

    var dialog: QBChatDialog!
    @IBOutlet  var btnBlockOnPopUp: UIButton!
    @IBOutlet  var btnSingleChatOnPopUp: UIButton!
    @IBOutlet  var viewChatOptionPopUp: UIView!
    @IBOutlet  var viewInsideChatOptionPopUp: UIView!

    var btnChatUser: UIButton!
    var isBlock: Bool!
    var arrayChat = [QBChatMessage]()
    var arrayMesssge = NSMutableArray()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    //    var messages = [Message]()
    //    var avatars = Dictionary<String, UIImage>()

    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.init(bubble:UIImage.init(named: "rightSideChatBG1") , capInsets: UIEdgeInsets.zero)


    //    JSQMessagesBubbleImageFactory.
    //    var outgoingBubbleImageView = JSQMessagesBubbleImage.init(messageBubble: UIImage.init(named: "rightSideChatBG1"), highlightedImage: UIImage.init(named: "rightSideChatBG1"))


    //    var incomingBubbleImageView =   JSQMessagesBubbleImage.init(messageBubble: UIImage.init(named: "LeftChat"), highlightedImage: UIImage.init(named: "LeftChat"))


    //    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.init(bubble: UIImage.jsq_bubbleRegularStroked(), capInsets: UIEdgeInsets.zero)



    //    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.init(bubble:UIImage.init(named: "LeftChat1") , capInsets: UIEdgeInsets.zero)

    //    var incomingBubbleImageView =   JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())

    //    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    //
    //
    //    var incomingBubbleImageView =   JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())



    override func viewDidLoad() {


        super.viewDidLoad()
        automaticallyScrollsToMostRecentMessage = true

        self.showLoadEarlierMessagesHeader = true;
        
//        self.showLoadEarlierMessagesHeader.description
//        self.showLoadEarlierMessagesHeader.description = "Cargar más mensaje"

        self.inputToolbar?.contentView?.backgroundColor = UIColor.white
        self.inputToolbar?.contentView?.textView?.placeHolder = "Mensaje"
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.rightBarButtonItem.setBackgroundImage(UIImage.init(named: "sendChatButton"), for: UIControlState.normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: UIControlState.normal)

        self.inputToolbar.contentView.backgroundColor = UIColor.lightGray


        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        self.collectionView?.backgroundColor = UIColor (colorLiteralRed: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1)


        senderId = String(format:"%d",ServiceClass.sharedInstance.currentUser.id )
        addMembersButton()

        senderDisplayName = ""



        self.title = dialog.name

        //        if !dialog.isJoined()
        //        {

        SVProgressHUD.show()
        dialog.join { (error) in
            SVProgressHUD.dismiss()
            print("\(String(describing: error))")
        }


        /// add pull to down refresh




    }

    override func viewWillAppear(_ animated: Bool) {
        ServiceClass.sharedInstance.dialogCurrent = dialog
        ServiceClass.sharedInstance.deletgate = self
        self.tabBarController?.tabBar.isHidden = true
        getChatHistory()

        //        finishReceivingMessage()
    }


    //MARK:
    // MARK: get chat history

    func getChatHistory()  {

        ServiceClass.sharedInstance.getMessges(dialogId: self.dialog.id!, count: 0)

    }





    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

        JSQSystemSoundPlayer.jsq_playMessageSentSound()




        let message = QBChatMessage()
        message.text =  text

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


        //            message.addedOccupantsIDs = dialog.occupantIDs

        message.dialogID = dialog.id

        sendMessage(message: message)

        //        self.addChatBubble(message: message, withIndex: (self.arrayChat.count))
        // Add message after add chat bubble
        self.arrayChat.append(message)

        //        self.txtChat.text = ""



        let jQMessage = JSQMessage.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)

        arrayMesssge.add(jQMessage!)


        //        sendMessage(text: text, sender: sender)

        finishSendingMessage()


    }



    func sendMessage(message: QBChatMessage) {

        //        var flag: Bool = false

        dialog.onBlockedMessage = {
            (error) -> Void in

            QMMessageNotificationManager.showNotification(withTitle: "SA_STR_ERROR".localized, subtitle: "Usted está bloqueado por el usuario", type: QMMessageNotificationType.warning)
            //            flag = true
            print(error!)
        }

        dialog.send(message, completionBlock: { (error) -> Void in

            if error != nil {
                QMMessageNotificationManager.showNotification(withTitle: "SA_STR_ERROR".localized, subtitle: "Error al enviar el mensaje", type: QMMessageNotificationType.warning)

                print(error!)
            }
            else
            {
                var chatMessageArray = [QBChatMessage]()
                chatMessageArray.append(message)
                ModelManager().insertIntoChatTable(dialogObjects: chatMessageArray)
            }
        })
    }




    //MARK: - JSQMessages CollectionView DataSource

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return arrayMesssge[indexPath.item] as! JSQMessageData
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {


        let message: JSQMessage = arrayMesssge[indexPath.row] as! JSQMessage

        if message.senderId == senderId
        {
            //  let ref = JSQMessagesBubbleImageFactory.init(bubble: UIImage.jsq_bubbleRegular(), capInsets: UIEdgeInsets.zero)

            // return ref?.outgoingMessagesBubbleImage(with: UIColor.blue)


            return  outgoingBubbleImageView?.outgoingMessagesBubbleImage(with: UIColor(red: 234.0/255.0, green: 209.0/255.0, blue: 241.0/255.0, alpha: 1.0))
        }

        //            return UIImageView(image: outgoingBubbleImageView!.image, highlightedImage: outgoingBubbleImageView!.highlightedImage)

        return outgoingBubbleImageView?.incomingMessagesBubbleImage(with: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0))


        //        return UIImageView(image: incomingBubbleImageView!.image, highlightedImage: incomingBubbleImageView!.highlightedImage)


    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        //        let message: JSQMessage = arrayMesssge[indexPath.row] as! JSQMessage
        //
        //        if message.senderId == senderId
        //        {
        return nil;
        //        }
        //        else
        //        {
        //
        //            let chatMessage = arrayChat[indexPath.row]
        //
        //
        ////            if(chatMessage.customParameters.count>0)
        ////            {
        //                setupAvatarImage(name: message.senderId, imageUrl: chatMessage.customParameters.value(forKey: "avatar") as? String, incoming: true)
        ////            let img: JSQMessagesAvatarImage = avatars[message.senderId] as! JSQMessagesAvatarImage
        //
        //
        //
        //
        //                return avatars[message.senderId]
        //
        ////                profile.sd_setImage(with: URL.init(string: (message.customParameters.value(forKey: "avatar") as! String)), placeholderImage: UIImage.init(named: "profile_pic"))
        ////            }
        ////            else
        ////            {
        //////                profile.image =  UIImage.init(named: "profile_pic")
        ////            }
        //        }
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return arrayMesssge.count
    }



    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)as! JSQMessagesCollectionViewCell
        //         let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

        cell.textView.textColor = UIColor.black

        let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor!, NSUnderlineStyleAttributeName: 1 as AnyObject]
        cell.textView.linkTextAttributes = attributes

        if(arrayChat[indexPath.row].customParameters.count > 0 && arrayChat[indexPath.row].customParameters["avatar"] != nil)
        {
            cell.avatarImageView .sd_setImage(with: URL.init(string: (arrayChat[indexPath.row].customParameters.value(forKey: "avatar") as! String)), placeholderImage: UIImage.init(named: "profile_pic"))
        }
        else
        {
            cell.avatarImageView.image =  UIImage.init(named: "profile_pic")
        }

        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.height/2
        cell.avatarImageView.layer.borderWidth = 1
        cell.avatarImageView.layer.masksToBounds = true

        cell.avatarImageView.isUserInteractionEnabled = true
        cell.avatarImageView.tag = Int(indexPath.row)

        let tabGesture = UITapGestureRecognizer.init(target: self, action: #selector(imageTapGesture(sender:)))

        cell.avatarImageView.addGestureRecognizer(tabGesture)




        //        profile.sd_setImage(with: URL.init(string: (message.customParameters.value(forKey: "avatar") as! String)), placeholderImage: UIImage.init(named: "profile_pic"))
        //            }
        //            else
        //            {
        ////                profile.image =  UIImage.init(named: "profile_pic")
        //            }


        return cell
    }
    //    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //
    //    }

    override public func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {

        let message = arrayMesssge[indexPath.item] as! JSQMessage

        // Sent by me, skip
        if message.senderId == senderId {
            return CGFloat(0.0);
        }

        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = arrayMesssge[indexPath.item - 1] as! JSQMessage;
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0);
            }
        }

        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }


    override  func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {

        let message : JSQMessage = arrayMesssge[indexPath.row] as! JSQMessage

        if(message.senderId != senderId)
        {
            if (indexPath.item - 1 > 0) {

                let previousMessage:JSQMessage = arrayMesssge[indexPath.item - 1] as! JSQMessage

                if (previousMessage.senderId == message.senderId) {
                    return 0.0;
                }
            }
            return 15
        }
        else
        {
            return 0.0
        }
    }



    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {


        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        //        if (indexPath.item % 3 == 0) {

        let message : JSQMessage = arrayMesssge[indexPath.row] as! JSQMessage
        //            JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date) // [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
        //        }

        //        return nil;

    }


    //    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat
    //    {
    //        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    //    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {

        let message: JSQMessage = arrayMesssge[indexPath.row] as! JSQMessage

        /**
         *  iOS7-style sender name labels
         */
        if (message.senderId == senderId) {
            return nil;
        }

        if (indexPath.item - 1 > 0) {

            let previousMessage:JSQMessage = arrayMesssge[indexPath.item - 1] as! JSQMessage

            if (previousMessage.senderId == message.senderId) {
                return nil;
            }
        }

        /**
         *  Don't specify attributes to use the defaults.
         */
        return NSAttributedString.init(string: message.senderDisplayName)

        //[[NSAttributedString alloc] initWithString:message.senderDisplayName];



    }


  
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {

        let tempArray = ModelManager.getInstance().getChatMessages(dialogId: self.dialog.id!, count: arrayChat.count)





        DispatchQueue.main.async{
            var indexPaths: [AnyObject] = []
            for i in 0..<tempArray.count
            {

                indexPaths.append(NSIndexPath.init(row: i, section: 0))
                //                self.addChatBubble(message: messages[i], withIndex: i)
                var name = ""
                if(tempArray[i].customParameters.count > 0 && tempArray[i].customParameters["name"] != nil)
                {
                    name = tempArray[i].customParameters.value(forKey: "name") as! String
                }

                let jQMessage = JSQMessage.init(senderId: String(format:"%d",tempArray[i].senderID), senderDisplayName: name, date: tempArray[i].dateSent, text: tempArray[i].text)

                //name
                //                self.arrayMesssge.add(jQMessage!)

                self.arrayMesssge.insert(jQMessage!, at: i)


                self.arrayChat.insert(tempArray[i], at: i)

                //            self.addChatBubble(message: messages[i])
            }

            //            self.arrayChat.ap

//            self.arrayChat.append(contentsOf: tempArray)
//
//
////            self.arrayChat.append(tempArray)
//
////            NSSortDescriptor *dateSentDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateSent" ascending:YES];
//
////            NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES];
//
//           // let sortDescriptore = NS
//
//            let datasource: NSMutableOrderedSet = NSMutableOrderedSet.init(array: self.arrayChat);
//
//
////            NSMutableOrderedSet *datasource = [self dataSourceWithDialogID:dialogID];
//
//
//            let sortDescriptor = NSSortDescriptor(key: "dateSent", ascending: true)
//
//            let idDescriptor = NSSortDescriptor(key: "ID", ascending: true)
//
//            datasource.sort(using: [sortDescriptor, idDescriptor])
//
//            self.arrayChat .removeAll()



            //            self.arrayChat .sorted(by: { (sortDescriptor, idDescriptor) -> Bool in
//
//            })



            self.collectionView.insertItems(at: indexPaths as! [IndexPath])

            // invalidate layout
            self.collectionView.collectionViewLayout.invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext())

//            self.collectionView.reloadItems(at: indexPaths as! [IndexPath])
        }


        //        self.finishReceivingMessage()

        //        self.finishSendingMessage(animated: true)




        //        ServiceClass.sharedInstance.getMessges(dialogId: self.dialog.id!, count: arrayChat.count)

    }
    //MARK: - JSQMessagesComposerTextViewPasteDelegate methods

    public func composerTextView(_ textView: JSQMessagesComposerTextView!, shouldPasteWithSender sender: Any!) -> Bool
    {
        if((UIPasteboard.general.image) != nil)
        {
            return false
        }

        return true
    }


    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOf: url as URL) {
                    let image = UIImage(data: data as Data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)

                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: diameter)

                    //                    let avatarImage = JSQMessagesAvatarFactory.avatar(with: image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }

        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name: name, incoming: incoming)
    }

    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)

        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)

        //        let nameLength = name.characters.count
        let initials : String = "hello1"

        //        let initials : String = name.substringToIndex(sender.startIndex.advancedBy(min(3, nameLength)))


        let userImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: color, textColor: UIColor.black, font: UIFont.systemFont(ofSize: CGFloat(13)), diameter: diameter)


        //        let userImage = JSQMessagesAvatarFactory.avatar(withUserInitials: initials, backgroundColor: color, textColor: UIColor.black, font: UIFont.systemFont(ofSize: CGFloat(13)), diameter: diameter)

        avatars[name] = userImage
    }



    //MARK:
    //MARK: Service Delegate

    func getChatMessage(messages: [QBChatMessage]) {

        DispatchQueue.main.async{
            for i in 0..<messages.count
            {
                //                self.addChatBubble(message: messages[i], withIndex: i)
                var name = ""
                if(messages[i].customParameters.count > 0 && messages[i].customParameters["name"] != nil)
                {
                    name = messages[i].customParameters.value(forKey: "name") as! String
                }

                let jQMessage = JSQMessage.init(senderId: String(format:"%d",messages[i].senderID), senderDisplayName: name, date: messages[i].dateSent, text: messages[i].text)

                //name
                self.arrayMesssge.add(jQMessage!)

                //            self.addChatBubble(message: messages[i])
            }


            self.arrayChat.append(contentsOf: messages)


            self.finishSendingMessage(animated: true)

        }

    }


    func groupChatMessageRecive(message: QBChatMessage, dialogeId: String) {

        //        DispatchQueue.main.async{

        let jQMessage = JSQMessage.init(senderId: String(format:"%d",message.senderID), senderDisplayName: message.customParameters.value(forKey: "name") as! String, date: message.dateSent, text: message.text)


        self.arrayMesssge.add(jQMessage!)

        self.arrayChat.append(message)

        var chatMessageArray = [QBChatMessage]()
        chatMessageArray.append(message)
        ModelManager().insertIntoChatTable(dialogObjects: chatMessageArray)

        self.finishReceivingMessage(animated: true)


        //        reloadtable()
        //        }

    }


    //MARK:
    //MARK: click on Opponent image
    func imageTapGesture(sender : UITapGestureRecognizer) {

        //        let img : UIImageView = sender.view as! UIImageView

        let tag: Int = sender.view!.tag


        let message: QBChatMessage =  arrayChat[tag]

        let id = NSNumber (value: Int(message.senderID))

        if(ServiceClass.sharedInstance.currentUser.id == dialog.userID)
        {
            btnSingleChatOnPopUp.tag = tag
            btnBlockOnPopUp.tag = tag

            viewChatOptionPopUp.isHidden = false

            btnBlockOnPopUp.setTitle("Bloquear", for: UIControlState.normal)
            isBlock = false

            let message: QBChatMessage =  arrayChat[btnSingleChatOnPopUp.tag]

            if(ServiceClass.sharedInstance.privacyListArray != nil)
            {
                var i = -1
                for privateUser in ServiceClass.sharedInstance.privacyListArray.privacyItems
                {
                    i = i+1

                    if(privateUser.userID == message.senderID)
                    {
                        isBlock = true
                        btnBlockOnPopUp.setTitle("Desatascar", for: UIControlState.normal)
                        break;
                    }
                }
            }
        }

        else{

            ServiceClass.sharedInstance.createSingleChat(name: nil, userid: id, completion: {(response, chatDialog) in

                guard let unwrappedResponse = response else {
                    print("Error empty response")
                    return
                }
                if let error = unwrappedResponse.error {
                    print(error.error as Any)
                    SVProgressHUD.showError(withStatus: error.error?.localizedDescription)
                }
                else {

                    //                    let singleChatVC: SingleChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "SingleChatViewController") as! SingleChatViewController

                    let singleChatVC: ChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController

                    singleChatVC.dialog = chatDialog

                    self.navigationController?.pushViewController(singleChatVC, animated: true)
                }

            })

        }


    }

    // MARK: sigle chat button click

    @IBAction func singleChatButtonClick(sender: UIButton)
    {
        viewChatOptionPopUp.isHidden = true

        let message: QBChatMessage =  arrayChat[sender.tag]

        let id = NSNumber (value: Int(message.senderID))
        //dddkk

        ServiceClass.sharedInstance.createSingleChat(name: nil, userid: id, completion: {(response, chatDialog) in

            guard let unwrappedResponse = response else {
                print("Error empty response")
                return
            }
            if let error = unwrappedResponse.error {
                print(error.error as Any)
                SVProgressHUD.showError(withStatus: error.error?.localizedDescription)
            }
            else {

                let singleChatVC: ChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController

                singleChatVC.dialog = chatDialog

                self.navigationController?.pushViewController(singleChatVC, animated: true)


            }

        })
    }
    // MARK: block user from group

    @IBAction func blockButtonClick(sender: UIButton)
    {
        let message: QBChatMessage =  arrayChat[sender.tag]
        viewChatOptionPopUp.isHidden = true
        ServiceClass.sharedInstance.blockUserIntoGroup(userId: message.senderID)




        var message1 = "¿Está seguro de bloquear?"

        if(self.isBlock == true)
        {
            message1 = "¿Está seguro de desbloquear?"
        }

        let alert = UIAlertController(title: "alerta", message: message1, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))

        //        alert.addAction(UIAlertAction(title: "Sí", style: UIAlertActionStyle.default, handler: nil))

        alert.addAction(UIAlertAction(title: "Sí", style: UIAlertActionStyle.default, handler: { (action) in

            if(self.isBlock == true)
            {
                ServiceClass.sharedInstance.unblockUserIntoGroup(userId: message.senderID)
            }
            else
            {
                ServiceClass.sharedInstance.blockUserIntoGroup(userId: message.senderID)
            }
        }))


        DispatchQueue.main.async{
            self.present(alert, animated: true, completion: nil)
        }

    }



    // MARK: Add notifiacation on navigationbar

    func addMembersButton(){
        btnChatUser = UIButton(type: UIButtonType.system)
        btnChatUser.setImage(UIImage.init(named: "groupChatIcon"), for: UIControlState.normal)
        btnChatUser.setImage(UIImage.init(named: "groupIcon"), for: UIControlState.selected)


        btnChatUser.frame = CGRect(x: 0, y: 0, width: 44, height: 44)


        btnChatUser.addTarget(self, action: #selector(onUsersButtonPressed(_:)), for: UIControlEvents.touchUpInside)

        btnChatUser.transform = CGAffineTransform(translationX: 20, y: 0)

        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: btnChatUser.frame)
        suggestButtonContainer.addSubview(btnChatUser)


        let customBarItem = UIBarButtonItem(customView: suggestButtonContainer)
        //        customBarItem.width = -20;
        //        customBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)

        self.navigationItem.rightBarButtonItem = customBarItem;

        //        self.navigationItem.rightBarButtonItem.setImageInsets:UIEdgeInsetsMake(10, 0, 0, 50)

    }



    func onUsersButtonPressed(_ sender : UIButton){




        if (sender.tag == 10)
        {
            // To Hide Menu If it already there


            sender.isSelected = false
            sender.backgroundColor=nil;
            sender.tag = 0;

            let viewMenuBack : UIView = view.subviews.last!

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.y = -1 * UIScreen.main.bounds.size.height

                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                viewMenuBack.removeFromSuperview()
            })

            return
        }

        sender.isEnabled = false
        sender.tag = 10

        sender.backgroundColor=UIColor.black;

        sender.isSelected = true

        //        sender.setImage(UIImage.init(named: "Cross"), for: UIControlState())



        let menuVC : GroupChatUsersViewController = self.storyboard!.instantiateViewController(withIdentifier: "GroupChatUsersViewController") as! GroupChatUsersViewController

        menuVC.dialog = self.dialog

        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 , y: 0 - UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false;
        ServiceClass.sharedInstance.deletgate = nil
        ServiceClass.sharedInstance.dialogCurrent = nil
        if(btnChatUser.tag == 10)
        {
            onUsersButtonPressed(btnChatUser)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.addSubview(viewChatOptionPopUp)
        collectionView.collectionViewLayout.springinessEnabled = false
    }
    
    
    
}
