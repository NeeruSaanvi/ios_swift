//
//  getChatListViewController.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 24/12/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit


class DialogTableViewCellModel: NSObject {

    var detailTextLabelText: String = ""
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?

    init(dialog: QBChatDialog) {
        super.init()

        switch (dialog.type){
        case .publicGroup:
            self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
        case .group:
            self.detailTextLabelText = "SA_STR_GROUP".localized
        case .private:
            self.detailTextLabelText = "SA_STR_PRIVATE".localized

            if dialog.recipientID == -1 {
                return
            }

            // Getting recipient from users service.
            //            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(dialog.recipientID)) {
            //                self.textLabelText = recipient.login ?? recipient.email!
            //            }
        }

        if self.textLabelText.isEmpty {
            // group chat

            if let dialogName = dialog.name {
                self.textLabelText = dialogName
            }
        }

        // Unread messages counter label

        if (dialog.unreadMessagesCount > 0) {

            var trimmedUnreadMessageCount : String

            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }

            self.unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            self.unreadMessagesCounterHiden = false

        }
        else {

            self.unreadMessagesCounterLabelText = nil
            self.unreadMessagesCounterHiden = true
        }

        // Dialog icon

        if dialog.type == .private {
            self.dialogIcon = UIImage(named: "profile_pic")
        }
        else {
            self.dialogIcon = UIImage(named: "group")
        }
    }
}


// MARK:
class getChatListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DialogModalDelegate {

    var arrayChatList = [QBChatDialog]()
    @IBOutlet weak var segmentController: UISegmentedControl!

    var arraySingleChatList = [QBChatDialog]()
    var arrayGroupChatList = [QBChatDialog]()
//    var arrayChatList = NSMutableArray()

    @IBOutlet weak var tableView: UITableView!

    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat"
        addSlideMenuButton()
        addNotificationButton()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        DialogModal.instance.delegate = self

//        DialogModal.instance.deletgate = self
        ServiceClass.sharedInstance.getDialogs()
//        getDialogs()
        //        ServiceClass.sharedInstance.deletgate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arrayChatList.count

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 64.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogcell", for: indexPath) as! DialogTableViewCell


        let chatDialog : QBChatDialog = arrayChatList[indexPath.row]

        QBChatDialog.initialize()
        

        

//        let chatDialog : QBChatDialog = arrayChatList[indexPath.row] as! QBChatDialog



        //        cell.isExclusiveTouch = true
        //        cell.contentView.isExclusiveTouch = true

        cell.tag = indexPath.row
        cell.dialogID = chatDialog.id!

        let cellModel = DialogTableViewCellModel(dialog: chatDialog)

        cell.dialogLastMessage?.text = chatDialog.lastMessageText
        cell.dialogName?.text = cellModel.textLabelText
//        cell.dialogTypeImage.image = cellModel.dialogIcon
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        cell.unreadMessageCounterHolder.isHidden = cellModel.unreadMessagesCounterHiden

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        //        if (ServicesManager.instance().isProcessingLogOut!) {
        //            return
        //        }

        let dialog : QBChatDialog = arrayChatList[indexPath.row] 

        if(dialog.type == QBChatDialogType.private)
        {
//            let singleChatVC: SingleChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "SingleChatViewController") as! SingleChatViewController

            let singleChatVC: ChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController


            singleChatVC.dialog = dialog

            self.navigationController?.pushViewController(singleChatVC, animated: true)
        }
        else{
            //        if(dialog.userID != 0)
            //        {
            //            self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
            //        }
            //        else
            //        {
            //            let dialog_toupdate = QBChatDialog(dialogID: dialog.id, type: QBChatDialogType.publicGroup)

            let chatVC : GroupChat = self.storyboard?.instantiateViewController(withIdentifier: "GroupChat") as! GroupChat

            chatVC.dialog = dialog
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    

//MARK:
    //MARK: Service Class Delegate

    func getDialogs(messages: [QBChatDialog]) {
        arrayGroupChatList = messages
        getList()
    }

    func getPrivateDialogs(messages: [QBChatDialog]) {
        arraySingleChatList = messages
        getList()
    }

    
    //MARK:
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //        ServiceClass.sharedInstance.deletgate = nil
    }

    // MARK:
    // MARK: search in list
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        arrayChatList.removeAll()

        if(searchText == "")
        {
            if(segmentController.selectedSegmentIndex == 0)
            {
                arrayChatList = arraySingleChatList;
            }
            else{
                 arrayChatList = arrayGroupChatList
            }

        }
        else
        {
                if(segmentController.selectedSegmentIndex == 0)
                {
                    for dialog in arraySingleChatList
                    {
                        if ((dialog.name!.range(of: searchText, options: .caseInsensitive)) != nil)
                        {

                            arrayChatList.append(dialog)
                        }
                    }
                }
                else
                {
                    for dialog in arrayGroupChatList
                    {
                        if ((dialog.name!.range(of: searchText, options: .caseInsensitive)) != nil)
                        {
                            arrayChatList.append(dialog)
                        }
                    }
                }
            }
        tableView?.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }


    @IBAction func segmentChangeTap(sender: UISegmentedControl)
    {

        ServiceClass.sharedInstance.getDialogs()

        self.getList()

    }


    func getList()
    {
        if(segmentController.selectedSegmentIndex == 0)
        {
            arrayChatList = arraySingleChatList
        }
        else
        {
            arrayChatList = arrayGroupChatList
        }

        DispatchQueue.main.async{
            self.tableView?.reloadData()
        }
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
