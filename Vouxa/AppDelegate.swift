//
//  AppDelegate.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GooglePlaces
//import Crashlytics
import Fabric
import Stripe
import Firebase
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging
//import firebase;

struct location {
    var locationObj : CLLocation!
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate,UNUserNotificationCenterDelegate
{
    let gcmMessageIDKey = "gcm.message_id"
    var currentLocation: CLLocation!
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var deviceToken : String!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        // Strip key
        STPPaymentConfiguration.shared().publishableKey = "pk_test_MeiHQRlan6SeuxrTAY2SWPHo"
        
        STPPaymentConfiguration.shared().smsAutofillDisabled = true
        
        // add crashlytics

        Crashlytics().debugMode = true
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self()])
        
        GMSPlacesClient.provideAPIKey(utilityObject.kGoogleAPIKey)
        
        
        
        // MARK: QUICKBLOX
        
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.setApplicationID(utilityObject.kQBApplicationID)
        QBSettings.setAuthKey(utilityObject.kQBAuthKey)
        QBSettings.setAuthSecret(utilityObject.kQBAuthSecret)
        QBSettings.setAccountKey(utilityObject.kQBAccountKey)
        QBSettings.setAutoReconnectEnabled(true)
        // enabling carbons for chat
        QBSettings.setCarbonsEnabled(true)
        
        // Enables Quickblox REST API calls debug console output.
        QBSettings.setLogLevel(QBLogLevel.network)
        
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        
//        QBSettings.setKeepAliveInterval(30);

        
        let barAppearace = UIBarButtonItem.appearance()
        
        barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for: UIBarMetrics.default)
        



        if UtilityClass().checkUserDefault(key: "userinfo")
        {
            
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
            let tabBarController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            
            



            let tabBar = tabBarController.tabBar as UITabBar


//            tabBar.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Font-Name", size: 13)!], for: .normal)


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
            
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController = tabBarController
        }
        
        
//        getCurrentLocation()

       
        
        UtilityClass.copyFile(fileName: "vouxa.sqlite")
        // Use Firebase library to configure APIs



         registerForRemoteNotification()

        FirebaseApp.configure()




        // Add observer for InstanceID token refresh callback.

        NotificationCenter.default.addObserver(self, selector:
            #selector(tokenRefreshNotification), name:
            NSNotification.Name.InstanceIDTokenRefresh, object: nil)


//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.tokenRefreshNotification),
//                                               name: .firInstanceIDTokenRefresh,
//                                               object: nil)


        SVProgressHUD .setMaximumDismissTimeInterval(10);
        
        return true
    }
    
    // MARK: Remote notifications
    
    func registerForRemoteNotification() {


        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })

            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
//            FIRMessaging.messaging().remoteMessageDelegate = self
//            Messaging.messaging().remoteMessageDelegate = self as? MessagingDelegate

        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()

//        
//        // Register for push in iOS 8
//        if #available(iOS 8.0, *) {
//            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
//            UIApplication.shared.registerUserNotificationSettings(settings)
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//        else {
//            // Register for push in iOS 7
//            UIApplication.shared.registerForRemoteNotifications(matching: [UIRemoteNotificationType.badge, UIRemoteNotificationType.sound, UIRemoteNotificationType.alert])
//        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

//        var token: String = ""
//        for i in 0..<deviceToken.count {
//            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
//        }
//        
//        print(token)
//        self.deviceToken = token

//         FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
//        FirebaseApp.
print("token === \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken

//        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
//        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)

//
//        FirebaseApp.instanceID().setAPNSToken(deviceToken, type:InstanceIDDeleteTokenHandler.Sandbox)
//        FirebaseApp.instanceID().setAPNSToken(deviceToken, type:InstanceIDDeleteTokenHandler.Prod)
//
//        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)

        if let refreshedToken = InstanceID.instanceID().token() {

            self.deviceToken = refreshedToken

            print("InstanceID token: \(refreshedToken)")
        }


//        self.deviceToken = FIRInstanceID.instanceID().token()!

        //print(token)

        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString

        let subscription: QBMSubscription! = QBMSubscription()

        subscription.notificationChannel = QBMNotificationChannel.APNS

        subscription.deviceUDID = deviceIdentifier

        subscription.deviceToken = deviceToken

        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            //
        }) { (response: QBResponse!) -> Void in
            //
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push failed to register with error: %@", error)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {


//        let userInfo = notification.request.content.userInfo
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }


        let type = userInfo["type" as NSString] as? [String:AnyObject]


        var body = ""

        var title = ""
        if(type != nil && type?["type"] as! String == "joinRequest")
        {
            BadgeClass.instance.getRequestList()
            let aps = userInfo["aps" as NSString] as? [String:AnyObject]
            let alert = aps?["alert"] as? [String:AnyObject]
            title = alert?["title"] as! String
            body = alert?["body"] as! String
        }
        else{
            let aps = userInfo["aps" as NSString] as? [String:AnyObject]

            title = "Chat"
            body = aps?["alert"] as! String

        }

        QMMessageNotificationManager.showNotification(withTitle: title, subtitle: body, type: QMMessageNotificationType.info)




        print("my push is: %@", userInfo)
//        guard application.applicationState == UIApplicationState.inactive else {
//            return
//        }
//        
//        guard let dialogID = userInfo["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String else {
//            return
//        }
//        
//        guard !dialogID.isEmpty else {
//            return
//        }
//        
//        
//                let dialogWithIDWasEntered: String? = ServiceClass.sharedInstance.dialogCurrent.id
//                if dialogWithIDWasEntered == dialogID {
//                    return
//                }
//
        //        ServicesManager.instance().notificationService.pushDialogID = dialogID
        
        // calling dispatch async for push notification handling to have priority in main queue
        //        DispatchQueue.main.async {
        
        //            ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(delegate: self)
        //        }
    }
    
    
    
    //MARK: Current Location
    
    func getCurrentLocation()
    {
        //        DispatchQueue.main.async{
        
        if(CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            
            //                if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            //                    self.locationManager.requestWhenInUseAuthorization()
            //                }else{
            //                    self.locationManager.startUpdatingLocation()
            //                }
            
            
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
            //                self.locationManager.startMonitoringSignificantLocationChanges()
            
        } else {
            
            
        }
        //        }
        
    }
    
    
    
    // MARK: - CoreLocation Delegate Methods
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray = locations as NSArray
        let locationObj1 = locationArray.lastObject as! CLLocation
        
        var loc = location.init()
        loc.locationObj = locationObj1
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        FBSDKAppEvents.activateApp()
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        application.applicationIconBadgeNumber = 0
        // Logging out from chat.
        
        ServiceClass.sharedInstance.chatUserDisconnect()
        
        
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // Logging in to chat.
        
        ServiceClass.sharedInstance.chatConnect()
        
        //        ServicesManager.instance().chatService.connect(completionBlock: nil)
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Override point for customization after application launch.
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    



    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }

    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }


        let type = userInfo["type" as NSString] as? [String:AnyObject]


        var body = ""

        var title = ""
        if(type != nil && type?["type"] as! String == "joinRequest")
        {
            BadgeClass.instance.getRequestList()
            let aps = userInfo["aps" as NSString] as? [String:AnyObject]
            let alert = aps?["alert"] as? [String:AnyObject]
             title = alert?["title"] as! String
             body = alert?["body"] as! String

        }
        else{
            let aps = userInfo["aps" as NSString] as? [String:AnyObject]

            title = "Chat"
            body = aps?["alert"] as! String

        }

        QMMessageNotificationManager.showNotification(withTitle: title, subtitle: body, type: QMMessageNotificationType.info)


//        let alert = UIAlertController(title: "alerta", message: userInfo., preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//        DispatchQueue.main.async{
//            self.present(alert, animated: true, completion: nil)
//        }



        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([])
    }


    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }

        // Print full message.
        print(userInfo)
        
        completionHandler()
    }

    func tokenRefreshNotification(_ notification: Notification) {

//        Messaging.messaging().apnsToken
        if let refreshedToken = InstanceID.instanceID().token() {

            self.deviceToken = refreshedToken

            print("InstanceID token: \(refreshedToken)")
        }

//        let storageRef: StorageReference = Storage.storage().reference

        // Connect to FCM since connection may have failed when attempted before having a token.
//        connectToFcm()
    }
}

