//
//  GroupChatUsersViewController.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 03/01/17.
//  Copyright © 2017 Pinesucceed. All rights reserved.
//

import UIKit

class GroupChatUsersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var dialog : QBChatDialog!
    var arrayChatUsers: NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()


        let messages = ModelManager().getChatMessages(dialogId: dialog.id!, count: -1)

        let arrayUsersId = NSMutableArray ()

        for message in messages
        {
            if(!arrayUsersId.contains(message.senderID) && message.senderID != ServiceClass.sharedInstance.currentUser.id )
            {
                arrayUsersId.add(message.senderID)
                arrayChatUsers.add(message)
            }
        }

        // Do any additional setup after loading the view.
    }


    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrayChatUsers.count
    }



    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let reuseIdentifier = "GroupCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventInfoCollectionViewCell



        let dic: QBChatMessage = arrayChatUsers[indexPath.row] as! QBChatMessage

        cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height/2
        cell.imgProfile.layer.borderWidth = 1

        cell.imgProfile.layer.masksToBounds = true

        cell.imgProfile.sd_setImage(with: URL.init(string: dic.customParameters.value(forKey: "avatar") as! String), placeholderImage: UIImage.init(named: "profile_pic"))

        cell.imgProfile.tag = indexPath.row

        let gesture : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self , action: #selector(tapOnImage(sender:)))
        //        cell.imgProfile.rounded
        //        cell.imgProfile.circle
        cell.imgProfile.addGestureRecognizer(gesture)


        return cell
    }



    func tapOnImage(sender: UITapGestureRecognizer)
    {
        let imgProfile: UIImageView = sender.view as! UIImageView

        let message: QBChatMessage =  arrayChatUsers[imgProfile.tag] as! QBChatMessage

        let id = NSNumber (value: Int(message.senderID))


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


//         arrayChatUsers[imgProfile.tag]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
