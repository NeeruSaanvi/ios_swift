//
//  AddEventConfirmationVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/6/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
//import FacebookShare
import FBSDKShareKit
import Social


class AddEventConfirmationVC: BaseViewController, FBSDKSharingDelegate {
    
    var eventName: String!
    var eventAddress: String!
    var eventDateTime: String!
    
    @IBOutlet weak var scrollView : TPKeyboardAvoidingScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView?.contentSizeToFit()
        addNotificationButton()

        


//        DialogsViewController().createGroup(groupName: eventName)



//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "notification bell"), style: .plain, target: self, action: #selector(notificationButtonTap))
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
    }


    @IBAction func sharebuttonClick(sender: UIButton)
    {



        


//        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()

//         let content: FBSDKShareAPI = FBSDKShareAPI()
//
////        content.contentURL = NSURL(string: self.contentURL)
//
//        content.message = "Fecha y hora del evento: \(eventDateTime)\nDirección del evento: \(eventAddress)"






        
        let content1 : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content1.contentURL = URL(string: "https://www.vouxa.com")

//        content.contentURL = NSURL(string: "<INSERT STRING HERE>")
        content1.contentTitle = eventName
        content1.contentDescription = ("Fecha y hora del evento: \(eventDateTime as String)\nDirección del evento: \(eventAddress as String)")

        let confirm = FBSDKMessageDialog.show(with: content1, delegate: self)

        if(confirm != nil)
        {

        }



        
        let dialog = FBSDKShareDialog.init();
        dialog.shareContent = content1
        
        dialog.fromViewController = self
        
        
        
        if(UIApplication.shared.canOpenURL(URL.init(string: "fbauth2://")!))
        {
            dialog.mode = FBSDKShareDialogMode.native
        }
        else{
            dialog.mode = FBSDKShareDialogMode.automatic
        }
//        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]]){
//            dialog.mode = FBSDKShareDialogModeNative;
//        }
//        else {
//            dialog.mode = FBSDKShareDialogModeBrowser; //or FBSDKShareDialogModeAutomatic
//        }
        
        
        
//        if(!dialog.canShow())
//        {
//            dialog.mode = FBSDKShareDialogMode.browser
//        }
        dialog.delegate = self
        print( dialog.show())


//        FBSDKShareDialog.show(from: self, with: content1, delegate: self)

//        print(FBSDKSharingDialog.show(dialog))


//        FBSDKShareDialog.show(from: self, with: content1, delegate: self)

        
        
        
//        let sharer = GraphSharer(content: content)
//        sharer.failsOnInvalidData = true
//        sharer.completion = { result in
//            // Handle share results
//        }
//        
//        try sharer.share()
        


        
//        content.contentTitle = eventName

//        content.contentDescription = "Fecha y hora del evento: \(eventDateTime)\nDirección del evento: \(eventAddress)"



//        let FBDilaog =

//        let shareDialog = FBSDKShareDialog()
//
//        shareDialog.delegate = self
//        shareDialog.fromViewController = self
//        shareDialog.shareContent = content
//
//        if !shareDialog.canShow() {
//            print("cannot show native share dialog")
//        }
//        else{
//        shareDialog.show()
//        }

//        let flag : Bool = FBSDKShareDialog().canShow()
//
//        if(!flag)
//        {
        
//        }
//        else
//        {
//            FBSDKShareDialog.show(from: self, with: content, delegate: self)
//        }
//
//        FBSDKShareDialog.canShow(<#T##FBSDKShareDialog#>)

    }


    
    @IBAction func backbuttonClick(sender: UIButton)
    {
        
        self.navigationController!.popViewController(animated: false)
        
        self.tabBarController?.selectedIndex = 0
    }


    //MARK: 
    //MARK: FBDelegates

    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!)
    {

    }
    
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!)
    {
        print("\(String(describing: sharer.debugDescription)) \(error.localizedDescription)")
//        shareWithFBSL()
    }
    
    
    func sharerDidCancel(_ sharer: FBSDKSharing!)
    {

    }

    
    func shareWithFBSL()
    {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)

            facebookSheet.setInitialText("Evento: \(eventName as String)\nFecha y hora del evento: \(eventDateTime as String)\nDirección del evento: \(eventAddress as String)")
            self.present(facebookSheet, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Cuentas", message: "Inicie sesión en una cuenta de Facebook para compartir.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
