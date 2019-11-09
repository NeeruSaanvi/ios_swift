//
//  SingleChatViewController.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/26/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

class SingleChatViewController: UIViewController, UITextViewDelegate, ServiceClassDelegate, UIScrollViewDelegate {

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

    var opponentId: UInt!

    var isBlock: Bool!
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        ServiceClass.sharedInstance.deletgate = self
        ServiceClass.sharedInstance.dialogCurrent = dialog
        getChatHistory()

        self.addKeyboardNotifications()

        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(scrollTab(gesture:)))

        messageCointainerScroll.addGestureRecognizer(gesture)


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

                        var image = try UIImage.init(data: Data.init(contentsOf: URL.init(string: (string:(userOponion?.customData)!) as! String)!))

                        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                        button.layer.masksToBounds = true
                        button.layer.cornerRadius = 20
                        button.setBackgroundImage(image, for: UIControlState.normal)

                    }
                    catch{

                    }


                }, errorBlock: { (response) in

                })

                break
            }
        }


        if(ServiceClass.sharedInstance.privacyListArray != nil)
        {
        var i = -1
        for privateUser in ServiceClass.sharedInstance.privacyListArray.privacyItems
        {
            i = i+1
            
            if(privateUser.userID == opponentId)
            {
                isBlock = true
            }
        }
        }

        // Do any additional setup after loading the view.
    }

    func profileImageClick()
    {
        var message = "¿Está seguro de bloquear?"
        
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
        
    }
    
    
    func getChatHistory()  {
        ServiceClass.sharedInstance.getMessges(dialogId: self.dialog.id!, count: 0)
    }

    
    //
    func addChatBubble(message: QBChatMessage) {

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
                messageText = message.text!
            }


            // Adding an incoming chat bubble
            let chatBubbleDataOpponent = ChatBubbleData(text: messageText, image:nil, date: NSDate(), type: .Opponent, profileImgFlag: false)

            let padding:CGFloat = lastMessageType == chatBubbleDataOpponent.type ? internalPadding/3.0 :  internalPadding


            let chatBubbleOpponent = ChatBubble(data: chatBubbleDataOpponent, startY: lastChatBubbleY + padding)

            self.messageCointainerScroll.addSubview(chatBubbleOpponent)

            lastChatBubbleY = chatBubbleOpponent.frame.maxY

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



    

    // MARK: Send Chat Button

    @IBAction func SendButtionClick(sender: UIButton)
    {
        txtChat.text = txtChat.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if(txtChat.text != "")
        {
            //            self.view.endEditing(true)

            let message = QBChatMessage()
            message.text = txtChat.text!
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

            sendMessage(message: message)

            self.addChatBubble(message: message)

            self.arrayChat.append(message)
            self.txtChat.text = ""

        }
    }



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
        //        self.typingTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatViewController.fireSendStopTypingIfNecessary), userInfo: nil, repeats: false)
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
        //            let numberOfSymbolsToCut = maxCharactersNumber - oldString.length
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
        //                btnSend.isEnabled = true
        //            } else {
        //                btnSend.isEnabled = false
        //            }
        //
        //
        //
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

//        UIView.animate(withDuration: 0.35, animations: { () -> Void in
//            self.buttomLayoutConstraint.constant = -keyboardFrame.size.height + (self.tabBarController?.tabBar.frame.size.height)!
//            //self.viewWidthConstraint.constant = 900
//            self.view.layoutIfNeeded()
//        })
//



        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            //self.buttomLayoutConstraint = keyboardFrame.size.height
            self.buttomLayoutConstraint.constant = -keyboardFrame.size.height + (self.tabBarController?.tabBar.frame.size.height)!
             self.view.layoutIfNeeded()

        }) { (completed: Bool) -> Void in
            self.moveToLastMessage()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.buttomLayoutConstraint.constant = 0.0
             self.view.layoutIfNeeded()
        }) { (completed: Bool) -> Void in
            self.moveToLastMessage()
        }
    }
    
    func scrollTab(gesture: UITapGestureRecognizer)
    {
        txtChat.resignFirstResponder()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        txtChat.resignFirstResponder()
    }
    
    
    //MARK: Service Class 
    
    func singleChatMessageRecive(message: QBChatMessage) {
        DispatchQueue.main.async{
        self.arrayChat.append(message)
        self.addChatBubble(message: message)
        
        var chatMessageArray = [QBChatMessage]()
        chatMessageArray.append(message)
        ModelManager().insertIntoChatTable(dialogObjects: chatMessageArray)
        //        reloadtable()
    }
        
    }
    
    
    func getChatMessage(messages: [QBChatMessage]) {
        
//        let i = self.arrayChat.count
        
//        self.arrayChat = messages

        DispatchQueue.main.async{
        for i in self.arrayChat.count..<messages.count
        {
            self.addChatBubble(message: messages[i])
        }
        
        self.arrayChat = messages
        }
        
//        for _ in i...messages.count
//        {
//            
//        }
        
        
//        for message in self.arrayChat!
//        {
//            self.addChatBubble(message: message)
//        }
        
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
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
    
}

