//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SDWebImage


protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32, withIdentifire: NSDictionary)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /**
    *  Array to display menu options
    */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
    *  Transparent button to hide menu
    */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
    *  Array containing menu options
    */
//    var arrayMenuOptions1 = [Dictionary<String,String>]()
//    
    var arrayMenuOptions:NSMutableArray = NSMutableArray();
    
    /**
    *  Menu button which was tapped to display the menu
    */
    var btnMenu : UIButton!
    
    /**
    *  Delegate of the MenuVC
    */
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenuOptions.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){
        
        
        arrayMenuOptions.add(["title":"Historial de anfitrión", "identifire":"HostHistoryVC","image":"Host_History"])
        arrayMenuOptions.add(["title":"Historial de asistente", "identifire":"AttendeeHistoryVC","image":"Attendy_History"])
        arrayMenuOptions.add(["title":"Filtros", "identifire":"FilterVC","image":"filter"])
        tblMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }


            if(index < 0)
            {
                delegate?.slideMenuItemSelectedAtIndex(index, withIdentifire: [:])
            }
            else
            {
                delegate?.slideMenuItemSelectedAtIndex(index, withIdentifire: arrayMenuOptions.object(at: Int(index)) as! NSDictionary)
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        
        
       let dic =  arrayMenuOptions.object(at: Int(indexPath.row)) as! NSDictionary
        
        lblTitle.text = dic.value(forKey: "title") as! String?
        
        let img : UIImageView = cell.contentView.viewWithTag(102) as! UIImageView
        
        img.image = UIImage.init(named: dic.value(forKey: "image") as! String)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu", for: indexPath)

        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel

        if lblTitle.text != "" && arrayMenuOptions.count > indexPath.row
        {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    @IBAction func logoutClick(sender: UIButton)
    {


        let imageCache : SDImageCache = SDImageCache.shared()
        imageCache.clearMemory();
        imageCache.clearDisk();

//
//        FBSDKAccessToken.setCurrentAccessToken(nil)
//        FBSDKProfile.setCurrentProfile(nil)
        
        // this is an instance function
        
        
        
//         let graphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: nil, httpMethod: "DELETE")
        
//        let dicfb = UtilityClass().getUserDefault(key: "userinfoFb") as! NSDictionary
       
//        if((FBSDKAccessToken.current()) != nil)
//        {
//            
//        }

       ServiceClass.sharedInstance.Qblogout()

        ServiceClass.sharedInstance.chatUserDisconnect()
        FBSDKLoginManager().logOut()
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        
//         let graphRequest = FBSDKGraphRequest.init(graphPath: "me/permissions", parameters: ["fields" :"email, user_birthday, public_profile"], httpMethod: "DELETE")
        
//        let graphRequest = FBSDKGraphRequest.init(graphPath: "me/permissions", parameters: ["fields" :"email, user_birthday, public_profile"], httpMethod: "DELETE")
        
//        let graphRequest = FBSDKGraphRequest(graphPath: "me/permissions", parameters: ["fields" : "email, user_birthday, public_profile"], htt)
        
        
        
//        let connection = FBSDKGraphRequestConnection()
//        connection.add(graphRequest, completionHandler: { (connection, result, error) in
//            
//            if error != nil {
//                
//               
//                
//                //do something with error
//                
//            } else {
//                
//                FBSDKLoginManager().logOut()
//                FBSDKAccessToken.setCurrent(nil)
//                FBSDKProfile.setCurrent(nil)
//                //do something with result
//                
//                //And this is the last method I tried
////                let cookie: HTTPCookie
//                let storage: HTTPCookieStorage = HTTPCookieStorage.shared
//                
//                for cookie in storage.cookies! {
//                    let domainName: String = cookie.domain
//                    let domainRange: Range = domainName.range(of: "facebook")!
//                    
//                   if !domainRange.isEmpty
//                   {
//                        storage.deleteCookie(cookie)
//                    }
//                    
//                    
//                    
//                    
////                    if domainRange.length > 0 {
////                        storage.deleteCookie(cookie)
////                    }
//                }
//                
//                
//            }
//            
//        })
//        
//        connection.start()
        
        
//        let deletepermission = FBSDKGraphRequest.init(graphPath: "me/permissions/", parameters: ["fields" :"email, user_birthday, public_profile"], httpMethod: "DELETE")
//        
//     
//        
//        deletepermission?.start(completionHandler: { (connection, result, error) in
//            
//            
//            print("the delete permission is \(result) \(connection)")
//        })
//        let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: [:], HTTPCookie)
        
        
        
        
//        let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, HTTPMethod: "DELETE")
        
        
        
        
//        deletepermission.startWithCompletionHandler({(connection,result,error)-> Void in
//            println("the delete permission is \(result)")
//            
//        })
        
        
//        FBSDKLoginManager.activeSession().closeAndClearTokenInformation()
        
        
        
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: "userinfoFb")
        defaults.removeObject(forKey: "userinfo")


        ModelManager().deleteAllData()
        
        let mainVc: ViewController = self.storyboard?.instantiateViewController(withIdentifier: "login") as! ViewController
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.window?.makeKeyAndVisible()
        
        appDelegate.window?.rootViewController = mainVc
        
    }
    
    
}
