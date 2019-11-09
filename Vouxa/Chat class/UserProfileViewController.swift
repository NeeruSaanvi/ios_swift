//
//  UserProfileViewController.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 3/31/17.
//  Copyright © 2017 Pinesucceed. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    var opponentId: UInt!
    var profileImage: UIImage!
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var btnExit: UIButton!

//    var block =  blockUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true;
        
        imgProfile.image = profileImage
        
        if( blockUser.isblock == true)
        {
            lblMessage.text = "¿Te gusta desbloquear el usuario?"
            btnBlock.setTitle("Desatascar", for: UIControlState.normal)
            
        }
        
        btnExit?.layer.cornerRadius=5;
        btnExit?.layer.borderColor=utilityObject.mainColor.cgColor;
        btnExit?.layer.borderWidth=1;
        
        self.title = "Bloquear/Desatascar"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBlockClick()
    {
        
        if(blockUser.isblock == true)
        {
            ServiceClass.sharedInstance.unblockUserInPrivateChat(Uid: self.opponentId)
            blockUser.isblock = false
            
            lblMessage.text = "¿Te gusta bloquear al usuario?"
            btnBlock.setTitle("Bloquear", for: UIControlState.normal)
            
            
            
        }
        else
        {
            ServiceClass.sharedInstance.blockUserInPrivateChat(Uid: self.opponentId)
            blockUser.isblock = true
            
            
            
            lblMessage.text = "¿Te gusta desbloquear el usuario?"
            btnBlock.setTitle("Desatascar", for: UIControlState.normal)
            
        }
        
        
    }

    
    @IBAction func btnExitClick()
    {
        self.navigationController!.popViewController(animated: true)
    }
    //desatascar
    //¿Te gusta desbloquear el usuario?
    
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
