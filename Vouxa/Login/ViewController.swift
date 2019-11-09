//
//  ViewController.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import FBSDKLoginKit
//import FBSDKCoreKit
//import Crashlytics
//import SVProgressHUD

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let base64Encoded = "R29vZCBKb2Ih"


        if let base64Decoded = NSData(base64Encoded: base64Encoded, options:   NSData.Base64DecodingOptions(rawValue: 0))
            .map({ NSString(data: $0 as Data, encoding: String.Encoding.utf8.rawValue) })
        {
            // Convert to a string
            print("Decoded:  \(String(describing: base64Decoded))")
        }

    }
    
    @IBAction func facebookLoginButtonClick(sender: UIButton)
    {
        
        //        APIModal().loginUser(email: "test1@gmail.com", facebookid: "test22", dob: "1991-01-12", name: "test", gender: "M", contactno: "", profilepic:"", target: self, action: #selector(ViewController.getLoginHandle(response:)))
        

        let loginManager = FBSDKLoginManager()
        //loginManager.loginBehavior = FBSDKLoginBehavior.Web
        
        loginManager.loginBehavior = FBSDKLoginBehavior.web
        
        
//login.loginBehavior = FBSDKLoginBehaviorWeb;
        
        
        loginManager.logIn(withReadPermissions: ["email","user_birthday","public_profile"], from: self) { (loginResult, error) in
            
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = loginResult!

                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
//                        loginManager.logOut()
                    }
                    else
                    {
                        Answers.logSignUp(withMethod: "Digits",
                                          success: true,
                                          customAttributes: [:])
                        
                        let loginManager = FBSDKLoginManager()
                        loginManager.logOut()
                    }
                }
                
            }
            else
            {
                // Logout if you want or display error message
                 let loginManager = FBSDKLoginManager()
                 loginManager.logOut()
            }
        }
    }
    
    
    func getFBUserData(){

        SVProgressHUD.show(withStatus: "por favor espera...")

        if((FBSDKAccessToken.current()) != nil){
           FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender, birthday"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    
                    
//                    var userID = FBSDKAccessToken as NSString
//                    var facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=large")

                    
//                    FBSDKAccessToken.current()
//                    var userID = user["id"] as NSString
//                    var facebookProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"
                    
                    
//                    "https://graph.facebook.com/\(fbuse .objectID)/picture?width=640&height=640"
                    
                    //https://graph.facebook.com/user_id/picture?type=large
                    
                    let dict : NSDictionary  = result as! [String : AnyObject] as NSDictionary
//                                        print(result!)
                                        print(dict)
                    var emailId = dict.value(forKey: "email")
                    
                    let facebookProfileUrl =  "http://graph.facebook.com/\(dict.value(forKey: "id") as! String)/picture?type=large"
                    
                    
//                    print(facebookProfileUrl)

                    if(emailId == nil)
                    {
                        emailId = "test@gmail.com"
                    }
                    
                    Answers.logSignUp(withMethod: "Digits",
                                                success: true,
                                                customAttributes: ["emailId": emailId as! String])
                    
                    
                    UtilityClass().saveUserDefault(key: "userinfoFb", value: dict)


                    var dob : String = dict.value(forKey: "birthday") as! String

                    print(dob)

                    if (dob == "" )
                    {
                        dob = "01/01/1990"
                    }

                    let formate = DateFormatter()
                    formate.dateFormat = "MM/dd/yyyy"


                    let date: Date =  formate.date(from: dob)! as Date
                    
                    formate.dateFormat = "yyyy-MM-dd"
                    

                    var gender = "M"
                    
                    if (dict.value(forKey: "gender") as! String).lowercased() == "female"
                    {
                        gender = "F"
                    }


                    self.logUser(emailId: emailId as! String, name: dict.value(forKey: "name") as! String, fbId: dict.value(forKey: "id") as! String)

                    
                    Answers.logLogin(withMethod: "Digits", success: true, customAttributes: ["emailId":emailId as! String])

                    APIModal().loginUser(email: emailId as! String, facebookid: dict.value(forKey: "id") as! String, dob: formate.string(from: date) as NSString, name: dict.value(forKey: "name") as! NSString, gender: gender as NSString, contactno: "", profilepic: facebookProfileUrl as NSString, target: self, action: #selector(ViewController.getLoginHandle(response:)))



//                    let str : String = "Hello"
//                    let count =  str.lengthOfBytes(using: String.Encoding.utf16)
                    
//                    let myString : String = "https://scontent.xx.fbcdn.net/v/t1.0-1/p200x200/13055480_768771953224200_1073884211224818858_n.jpg?oh=4a569c752afa3b19c542f6fb8cecfa52&oe=58B841AF"
                    
                    
//                     let length = countElements(myString)
//                    let length = accessibilityElementCount(myString)
//                     = count(myString)
                    
                    
//                    print(myString.characters.count)
                    
                    
                    
                    // APIModal().loginUser(email: dict.value(forKey: "email") as! String, facebookid: dict.value(forKey: "id") as! String, dob: formate.string(from: date) as NSString, name: dict.value(forKey: "name") as! NSString, gender: gender as NSString, contactno: "", profilepic: "https://scontent.xx.fbcdn.net/v/t1.0-1/p200x200/13055480_768771953224200_1073884211224818858_n.jpg?oh=4a569c752afa3b19c542f6fb8cecfa52&oe=58B841AF", target: self, action: #selector(ViewController.getLoginHandle(response:)))
                    
                    
                    //https://scontent.xx.fbcdn.net/v/t1.0-1/p200x200/13055480_768771953224200_1073884211224818858_n.jpg?oh=4a569c752afa3b19c542f6fb8cecfa52&oe=58B841AF
                    
                    
                    //
                    //
                    //                    UtilityClass().saveUserDefault(key: "userinfo", value: dict)
                    //
                    //
                    //                    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                    //
                    //
                    //                    let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "tabBarController")
                    //
                    //                    appDelegate.window?.rootViewController = initialViewController
                    //                    appDelegate.window?.makeKeyAndVisible()
                    //
                    
                }
            })
        }
    }
    
    func logUser(emailId: String, name: String, fbId: String) {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
//        ["emailId": dict.value(forKey: "email")
        Crashlytics.sharedInstance().setUserEmail(emailId)
        Crashlytics.sharedInstance().setUserIdentifier(fbId)
        Crashlytics.sharedInstance().setUserName(name)
    }
    
    func getLoginHandle(response : AnyObject) {
        
        let jsonResult : Dictionary = (response as? Dictionary<String, AnyObject>)!

        SVProgressHUD.dismiss()

        if (jsonResult["error"]as! Bool) == true
        {
            SVProgressHUD.showError(withStatus: jsonResult["message"] as! String!)
        }
        else
        {
           let dicTemp:NSDictionary = jsonResult["data"] as! NSDictionary
            
            if(dicTemp.value(forKey: "isNewUser") as! Bool == false  )
            {
                self.moveDashBoard(userDic: dicTemp)

//                let password = dicTemp.value(forKey: "facebookid") as! String + "123456"
//
//                let loginUsername = (dicTemp.value(forKey: "facebookid") as! String)
//
//                SVProgressHUD.show(withStatus: "por favor espera...")
//
//                ServiceClass.sharedInstance.login(userLogin: loginUsername, password: password, completion: { (response, success) in
//
//                    SVProgressHUD.dismiss()
//
//                    if(success)
//                    {
//                        let paramter = QBUpdateUserParameters()
//
//
//                        paramter.customData = dicTemp.value(forKeyPath: "profilepic") as? String
//
//                        paramter.fullName = dicTemp.value(forKeyPath: "name") as? String
//
//
//
//                        QBRequest.updateCurrentUser(paramter, successBlock: { (response, updatedUser) in
//
//                            print("update Profile in quickblox")
//                            print("\(updatedUser)")
//
//                        }, errorBlock: { (response) in
//                            print("\(response.error)")
//                        })


//                    }
//                    else
//                    {
//                        self.signUpcall(dicTemp: dicTemp)
//                    }
//                })
            }
            else
            {
                self.signUpcall(dicTemp: dicTemp)
            }
        }
    }


    func signUpcall(dicTemp: NSDictionary)
    {

        let users = QBUUser()


        let password = dicTemp.value(forKey: "facebookid") as! String + "123456"

        let loginUsername = (dicTemp.value(forKey: "facebookid") as! String)

        SVProgressHUD.show(withStatus: "por favor espera...")

        users.login = loginUsername
        users.password = password
        users.facebookID = (dicTemp.value(forKey: "facebookid") as! String)
        let arr = (dicTemp.value(forKey: "email") as! String) .components(separatedBy: "@")


        if(arr.count>1)
        {
            //(dicTemp.value(forKey: "email") as! String)//
            users.email = (arr[0] as String) + "_" + (dicTemp.value(forKey: "id") as! String) + "@" + (arr[1] as String)
        }

        ServiceClass.sharedInstance.signUp (user: users, completion: { (response, success) in

            if(success)
            {
                self.moveDashBoard(userDic: dicTemp)
            }
            else
            {
                SVProgressHUD.showError(withStatus: response?.error.debugDescription)
            }
            
        })



//        let completion = {(response: QBResponse?, createdDialog: QBUUser?) -> Void in
//            
//            
//            guard let unwrappedResponse = response else {
//                print("Error empty response")
//                return
//            }
//            
//            if let error = unwrappedResponse.error {
//                print(error.error as Any)
//                SVProgressHUD.showError(withStatus: error.error?.localizedDescription)
//            }
//            else {
//
////                let completion = {(success: Bool) -> Void in
////
////                    if(success)
////                    {
////                        self.moveDashBoard(userDic: dicTemp)
////                    }
////
////                }
//
////                AppDelegate().loginIntoChat(dicUser: dicTemp,completion: completion)
//            }
//        }
//
//         SVProgressHUD.show(withStatus: "por favor espera...")
//
//        signUpInQuickBlox(dicUser: dicTemp, completion: completion)

        
    }



    func moveDashBoard(userDic: NSDictionary)
    {
        UtilityClass().saveUserDefault(key: "userinfo", value: userDic)
        
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        
        
        let tabBarController: UITabBarController = self.storyboard!.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        
        
        //                                let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "tabBarController")
        
        let tabBar = tabBarController.tabBar as UITabBar
        
        let tabBarItem1 = tabBar.items![0] as UITabBarItem
        let tabBarItem2 = tabBar.items![1] as UITabBarItem
        let tabBarItem3 = tabBar.items![2] as UITabBarItem
        let tabBarItem4 = tabBar.items![3] as UITabBarItem
        
        
        
        let map_selected: UIImage! = UIImage(named: "map_selected")?.withRenderingMode(.alwaysOriginal)
        
        let list_selected: UIImage! = UIImage(named: "list_selected")?.withRenderingMode(.alwaysOriginal)
        
        let add_selected: UIImage! = UIImage(named: "add_selected")?.withRenderingMode(.alwaysOriginal)
        
        let filter_selected: UIImage! = UIImage(named: "chat_selected")?.withRenderingMode(.alwaysOriginal)
        
        
        tabBarItem1.selectedImage = map_selected
        tabBarItem2.selectedImage = list_selected
        tabBarItem3.selectedImage = add_selected
        tabBarItem4.selectedImage = filter_selected
        
        
        
        DispatchQueue.main.async{
            appDelegate.window?.makeKeyAndVisible()
            
            appDelegate.window?.rootViewController = tabBarController
        }
    }
    
    
//    func signUpInQuickBlox(dicUser: NSDictionary, completion: ((_ response: QBResponse?, _ createdDialog: QBUUser) -> Void)?)
//    {
//        
////        let dicUser : NSDictionary = UtilityClass().getUserDefault(key: "userinfo") as! NSDictionary
//        
//        let user = QBUUser()
//        //        user.id = userId
//        user.password = dicUser.value(forKey: "facebookid") as! String + "123456"
//        
//        user.login = (dicUser.value(forKey: "facebookid") as! String)
//        
//        let arr = (dicUser.value(forKey: "email") as! String) .components(separatedBy: "@")
//        
//        
//        if(arr.count>1)
//        {
//            user.email = (arr[0] as String) + "_" + (dicUser.value(forKey: "id") as! String) + "@" + (arr[1] as String)
//        }
//        
////        QBRequest.signUp(user, successBlock: { (response, user) in
////            
////            completion?(response, user!)
////            
////        }) { (response) in
////            
////            completion?(response, user)
////        }
//
//    }


    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

