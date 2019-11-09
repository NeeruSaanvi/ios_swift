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
//    var locationObj : CLLocation!
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate,UNUserNotificationCenterDelegate
{
    let gcmMessageIDKey = "gcm.message_id"
    var currentLocation: CLLocation!
    var window: UIWindow?
//    var locationManager = CLLocationManager()
    var deviceToken : String!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        



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
            Messaging.messaging().remoteMessageDelegate = self as? MessagingDelegate

        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()


    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

//
print("token === \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken

        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)

        if let refreshedToken = InstanceID.instanceID().token() {

            self.deviceToken = refreshedToken

            print("InstanceID token: \(refreshedToken)")
        }


    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push failed to register with error: %@", error)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {


//
    }
    
    
    
    //MARK: Current Location
    

    

    
    
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
        

        
        
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // Logging in to chat.
        
        //        ServicesManager.instance().chatService.connect(completionBlock: nil)
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Override point for customization after application launch.
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    



//    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
//        print(remoteMessage.appData)
//    }

    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
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

