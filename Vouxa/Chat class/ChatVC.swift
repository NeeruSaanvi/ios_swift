//
//  ChatVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 20/12/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITextViewDelegate, ServiceClassDelegate, UIScrollViewDelegate {

    //    static let chatInstance = ChatVC()
    //    var unreadMessages: [QBChatMessage]?

    var arrayChat = [QBChatMessage]()
    //    @IBOutlet weak var tableView : UITableView!
    var dialog: QBChatDialog!

    @IBOutlet weak var txtChat: UITextView!
    @IBOutlet weak var btnSend: UIButton!

    var typingTimer: Timer?
    let maxCharactersNumber = 1024 // 0 - unlimited


    @IBOutlet weak var messageCointainerScroll: UIScrollView!
    @IBOutlet weak var buttomLayoutConstraint: NSLayoutConstraint!
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 30.0
    var lastMessageType: BubbleDataType?

    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var btnSingleChat: UIButton!
    @IBOutlet weak var viewChatOption: UIView!
    @IBOutlet weak var viewInsideChatOption: UIView!

    var btnChatUser: UIButton!
    var isBlock: Bool!
    
    
    
    
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addKeyboardNotifications()

        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(scrollTab(gesture:)))

        messageCointainerScroll.addGestureRecognizer(gesture)

        //        addSlideMenuButton()
        addMembersButton()

        self.title = dialog.name

        //        if !dialog.isJoined()
        //        {
        dialog.join { (error) in

            print("\(String(describing: error))")
        }

        //        }

        //        ServiceClass.sharedInstance.deletgate = self

        
        // Do any additional setup after loading the view.
    }


    override func viewWillAppear(_ animated: Bool) {
        ServiceClass.sharedInstance.dialogCurrent = dialog
        ServiceClass.sharedInstance.deletgate = self
        getChatHistory()
    }


    //MARK:
    // MARK: get chat history

    func getChatHistory()  {

         ServiceClass.sharedInstance.getMessges(dialogId: self.dialog.id!, count: 0)
        
        
        /*QBRequest.countOfMessages( forDialogID: dialog.id!, extendedRequest: nil, successBlock: {(response: QBResponse!, count: UInt) in
            //                var countSkip = 0
            //                if(count>100)
            //                {
            //                    countSkip = Int(count) - 100;
            //                }
            //
            //                let resPage = QBResponsePage(limit:100, skip: Int(countSkip))


            for i in 0...Int(count)/100
            {
                let resPage = QBResponsePage(limit:100, skip: Int(i) * 100)

                QBRequest.messages(withDialogID: self.dialog.id!, extendedRequest: nil, for: resPage, successBlock: { (response, messages, pages) in

                    self.arrayChat = messages!
                    var j:  Int = 0

                    for message in self.arrayChat!
                    {
                        self.addChatBubble(message: message, withIndex: j)
                        j += 1
                    }

                }, errorBlock: { (respose) in

                })

            }
        }, errorBlock: {(response: QBResponse!) in

        })*/
    }



    //
    func addChatBubble(message: QBChatMessage, withIndex: Int) {

        if(message.senderID == ServiceClass.sharedInstance.currentUser.id)
        {
            // Adding an out going chat bubble
            let chatBubbleDataMine = ChatBubbleData(text: message.text, image: nil, date: NSDate(), type: .Mine, profileImgFlag: false)

            let padding:CGFloat = lastMessageType == chatBubbleDataMine.type ? internalPadding/3.0 :  internalPadding

            let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: lastChatBubbleY + padding)


            self.messageCointainerScroll.addSubview(chatBubbleMine)


            lastChatBubbleY = chatBubbleMine.frame.maxY

            lastMessageType = .Mine
            //            if(message.customParameters.count>0)
            //            {
            //                let heightImage = chatBubbleMine.frame.size.height > 50 ? 50 : chatBubbleMine.frame.size.height
            //
            //                let profile : UIImageView = UIImageView.init(frame: CGRect.init(x: chatBubbleMine.frame.size.width + chatBubbleMine.frame.origin.x + 4, y: chatBubbleMine.frame.origin.y, width: heightImage, height: heightImage))
            //
            //                self.messageCointainerScroll.addSubview(profile)
            //
            //                profile.sd_setImage(with: URL.init(string: (message.customParameters.value(forKey: "avatar") as! String)), placeholderImage: UIImage.init(named: "profile_pic"))
            //
            //                profile.layer.cornerRadius = profile.frame.size.height/2
            //                profile.layer.borderWidth = 1
            //                profile.layer.masksToBounds = true
            //
            //            }


            lastMessageType = .Mine
        }
        else
        {

            var messageText: String = message.text!

            if(message.customParameters.count>0)
            {
                messageText = message.customParameters.value(forKey: "name") as! String + ":\n" +  message.text!
            }


            // Adding an incoming chat bubble
            let chatBubbleDataOpponent = ChatBubbleData(text: messageText, image:nil, date: NSDate(), type: .Opponent, profileImgFlag: true)

            let padding:CGFloat = lastMessageType == chatBubbleDataOpponent.type ? internalPadding/3.0 :  internalPadding


            let chatBubbleOpponent = ChatBubble(data: chatBubbleDataOpponent, startY: lastChatBubbleY + padding)

            self.messageCointainerScroll.addSubview(chatBubbleOpponent)

            lastChatBubbleY = chatBubbleOpponent.frame.maxY



            let heightImage = chatBubbleOpponent.frame.size.height > 50 ? 50 : chatBubbleOpponent.frame.size.height


            let profile : UIImageView = UIImageView.init(frame: CGRect.init(x:chatBubbleOpponent.frame.origin.x - 54, y: chatBubbleOpponent.frame.origin.y, width:  heightImage, height: heightImage))

            self.messageCointainerScroll.addSubview(profile)

            profile.layer.cornerRadius = profile.frame.size.height/2
            profile.layer.borderWidth = 1
            profile.layer.masksToBounds = true

            profile.isUserInteractionEnabled = true
            profile.tag = withIndex

            let tabGesture = UITapGestureRecognizer.init(target: self, action: #selector(imageTapGesture(sender:)))

            profile.addGestureRecognizer(tabGesture)


            if(message.customParameters.count>0)
            {
                profile.sd_setImage(with: URL.init(string: (message.customParameters.value(forKey: "avatar") as! String)), placeholderImage: UIImage.init(named: "profile_pic"))
            }
            else
            {
                profile.image =  UIImage.init(named: "profile_pic")
            }

            lastMessageType = .Opponent


        }


        self.messageCointainerScroll.contentSize = CGSize.init(width: messageCointainerScroll.frame.width, height: lastChatBubbleY + internalPadding)

        self.moveToLastMessage()



    }


    func moveToLastMessage() {

        if messageCointainerScroll.contentSize.height > messageCointainerScroll.frame.height {
            let contentOffSet = CGPoint.init(x: 0.0, y: messageCointainerScroll.contentSize.height - messageCointainerScroll.frame.height)
            //            CGPointMake(0.0, messageCointainerScroll.contentSize.height - messageCointainerScroll.frame.height)
            self.messageCointainerScroll.setContentOffset(contentOffSet, animated: true)
        }
    }



    //MARK:
    //MARK: click on Opponent image
    func imageTapGesture(sender : UITapGestureRecognizer) {

        let img : UIImageView = sender.view as! UIImageView






        let message: QBChatMessage =  arrayChat[img.tag]

        let id = NSNumber (value: Int(message.senderID))

        if(ServiceClass.sharedInstance.currentUser.id == dialog.userID)
        {
            btnSingleChat.tag = img.tag
            btnBlock.tag = img.tag
            viewChatOption.isHidden = false
            
            btnBlock.setTitle("Bloquear", for: UIControlState.normal)
            isBlock = false
            
            let message: QBChatMessage =  arrayChat[btnSingleChat.tag]
            
            if(ServiceClass.sharedInstance.privacyListArray != nil)
            {
            var i = -1
            for privateUser in ServiceClass.sharedInstance.privacyListArray.privacyItems
            {
                i = i+1
                
                if(privateUser.userID == message.senderID)
                {
                    isBlock = true
                    btnBlock.setTitle("Desatascar", for: UIControlState.normal)
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
        viewChatOption.isHidden = true

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

                let singleChatVC: SingleChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "SingleChatViewController") as! SingleChatViewController

                singleChatVC.dialog = chatDialog

                self.navigationController?.pushViewController(singleChatVC, animated: true)


            }

        })
    }
    // MARK: block user from group

    @IBAction func blockButtonClick(sender: UIButton)
    {
        let message: QBChatMessage =  arrayChat[sender.tag]
        viewChatOption.isHidden = true
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


    // MARK:
    // MARK: Send message

    @IBAction func SendButtionClick(sender: UIButton)
    {
        txtChat.text =  txtChat.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        
//        let params = NSMutableDictionary()
        if(txtChat.text != "")
        {
            //            self.view.endEditing(true)

            let message = QBChatMessage()
            message.text =  txtChat.text!
            
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

            self.addChatBubble(message: message, withIndex: (self.arrayChat.count))
            // Add message after add chat bubble
            self.arrayChat.append(message)

            self.txtChat.text = ""

        }
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
            }
            else
            {
                var chatMessageArray = [QBChatMessage]()
                chatMessageArray.append(message)
                ModelManager().insertIntoChatTable(dialogObjects: chatMessageArray)
            }
        })
    }


    //MARK:

    // MARK: UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        //        super.textViewDidChange(textView)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        //        // Prevent crashing undo bug
        //        let currentCharacterCount = textView.text?.length ?? 0
        //
        //        if (range.length + range.location > currentCharacterCount) {
        //            return false
        //        }
        //
        //        if !QBChat.instance().isConnected { return true }
        //
        //        if let timer = self.typingTimer {
        //            timer.invalidate()
        //            self.typingTimer = nil
        //
        //        } else {
        //
        //            self.sendBeginTyping()
        //        }
        //
        ////        self.typingTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatViewController.fireSendStopTypingIfNecessary), userInfo: nil, repeats: false)
        //
        //        if maxCharactersNumber > 0 {
        //
        //            if currentCharacterCount >= maxCharactersNumber && text.length > 0 {
        //
        //                self.showCharactersNumberError()
        //                return false
        //            }
        //
        //            let newLength = currentCharacterCount + text.length - range.length
        //
        //            if  newLength <= maxCharactersNumber || text.length == 0 {
        //                return true
        //            }
        //
        //            let oldString = textView.text ?? ""
        //
        ////            let numberOfSymbolsToCut = maxCharactersNumber - oldString.length
        //
        //            var stringRange = NSMakeRange(0, min(text.length, numberOfSymbolsToCut))
        //
        //
        //            // adjust the range to include dependent chars
        //            stringRange = (text as NSString).rangeOfComposedCharacterSequences(for: stringRange)
        //
        //            // Now you can create the short string
        //            let shortString = (text as NSString).substring(with: stringRange)
        //
        //            let newText = NSMutableString()
        //            newText.append(oldString)
        //            newText.insert(shortString, at: range.location)
        //            textView.text = newText as String
        //
        //            self.showCharactersNumberError()
        //
        //            self.textViewDidChange(textView)
        //
        //
        //            if newLength > 0 {
        //              btnSend.isEnabled = true
        //            } else {
        //                btnSend.isEnabled = false
        //                }
        //            return false
        //        }

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        //        super.textViewDidEndEditing(textView)

        self.fireSendStopTypingIfNecessary()
    }

    func fireSendStopTypingIfNecessary() -> Void {

        if let timer = self.typingTimer {

            timer.invalidate()
        }

        self.typingTimer = nil
        self.sendStopTyping()
    }

    func sendBeginTyping() -> Void {
        self.dialog.sendUserIsTyping()
    }

    func sendStopTyping() -> Void {

        self.dialog.sendUserStoppedTyping()
    }

    func showCharactersNumberError() {
        let title  = "SA_STR_ERROR".localized;
        let subtitle = String(format: "The character limit is %lu.", maxCharactersNumber)
        QMMessageNotificationManager.showNotification(withTitle: title, subtitle: subtitle, type: .error)
    }



    func addKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    // MARK:- key board Notification
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            //self.buttomLayoutConstraint = keyboardFrame.size.height
            self.buttomLayoutConstraint.constant = -keyboardFrame.size.height + (self.tabBarController?.tabBar.frame.size.height)!

        }) { (completed: Bool) -> Void in
            self.moveToLastMessage()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.buttomLayoutConstraint.constant = 0.0
        }) { (completed: Bool) -> Void in
            self.moveToLastMessage()
        }
    }


    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        txtChat.resignFirstResponder()
    }

    func scrollTab(gesture: UITapGestureRecognizer)
    {
        txtChat.resignFirstResponder()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillDisappear(_ animated: Bool) {

        ServiceClass.sharedInstance.deletgate = nil
        ServiceClass.sharedInstance.dialogCurrent = nil
        if(btnChatUser.tag == 10)
        {
            onUsersButtonPressed(btnChatUser)
        }
    }



    //MARK:
    //MARK: Service Delegate

    func getChatMessage(messages: [QBChatMessage]) {
        
        DispatchQueue.main.async{
        for i in self.arrayChat.count..<messages.count
        {
            self.addChatBubble(message: messages[i], withIndex: i)
            
//            self.addChatBubble(message: messages[i])
        }
        
        self.arrayChat = messages
        }
        
        
        
//        var j:  Int = self.arrayChat.count
//        
//        self.arrayChat = messages
//        
//        for message in self.arrayChat
//        {
//            self.addChatBubble(message: message, withIndex: j)
//            j += 1
//        }
        
    }
    
    
    func groupChatMessageRecive(message: QBChatMessage, dialogeId: String) {

DispatchQueue.main.async{

        self.addChatBubble(message: message, withIndex: (self.arrayChat.count))
        // Add message after add chat bubble
        self.arrayChat.append(message)
        
        var chatMessageArray = [QBChatMessage]()
        chatMessageArray.append(message)
        ModelManager().insertIntoChatTable(dialogObjects: chatMessageArray)
        
        //        reloadtable()
    }

    }


    //    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
    //            arrayChat?.append(message)
    //            reloadtable()
    //    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */


    // Mark: Add notifiacation on navigationbar

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
        
        sender.backgroundColor=UIColor.white;
        
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
    
    
    
    
    
    
    
}


