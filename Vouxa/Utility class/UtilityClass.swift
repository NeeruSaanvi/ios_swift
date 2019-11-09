//
//  UtilityClass.swift
//  MOCSwift
//
//  Created by Piyush Agarwal on 9/22/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

//var B: String { get }
//
//#defer CFURLGetBaseURL("192.168.1.12:2136/api/ApiService/": CFURL!)

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE =  UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPAD =  UIDevice.current.userInterfaceIdiom == .pad
}


struct utilityObject {
    //    static var baseUrl = "http://192.168.1.12:2222/api/ApiService/"
    
    static var kGoogleAPIKey = ""
    static var kGoogleAPINSErrorCode = 42
    
    static var mainColor = UIColor.init(colorLiteralRed: 85/255.0, green: 6/255.0, blue: 121/255.0, alpha: 1)
    
    static var baseUrl = ""
    
    static let kQBApplicationID:UInt = 12
    static let kQBAuthKey = ""
    static let kQBAuthSecret = ""
    static let kQBAccountKey = ""
    
    static let kStatusAccepted = "Accepted"
    static let kStatusNoRequested = "Not Requested"
    static let kStatusDeclined = "Declined"
    static let kStatusPending = "Pending"
    
}

class UtilityClass: NSObject {
    
    
    
    func isIPHONE () -> Bool {
        
        if   UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
        {
            return true
        }
        
        return false
    }
    
    //MARK: Get ViewCOntroller From First StoryBorad
    func getStoryBoradFromFirst() -> UIStoryboard
    {
        var storyboradName : String = "Main_iphone"
        
        if !isIPHONE()
        {
            storyboradName = "main_iPad"
        }
        
        return UIStoryboard.init(name: storyboradName, bundle: nil)
        
    }
    
    
    //MARK: Get ViewCOntroller From First StoryBorad
    func getStoryBoradFromSecond() -> UIStoryboard
    {
        var storyboradName : String = "Main_iphone1"
        
        if !isIPHONE()
        {
            storyboradName = "main_iPad1"
        }
        
        return UIStoryboard.init(name: storyboradName, bundle: nil)
        
    }
    
    
    
    //MARK: Get ViewCOntroller From First StoryBorad
    func getStoryBoradFromThird() -> UIStoryboard
    {
        var storyboradName : String = "Main_iphone2"
        
        if !isIPHONE()
        {
            storyboradName = "main_iPad2"
        }
        
        return UIStoryboard.init(name: storyboradName, bundle: nil)
        
    }
    
    
    
    
    //MARK: SAFE VALUE IN UserDefault
    func saveUserDefault(key: String , value : Any) {
        
        UserDefaults.standard.set(value, forKey: key)
        
    }
    
    //MARK: GET VALUE FROM UserDefault
    func getUserDefault(key: String) -> Any {
        
        return UserDefaults.standard.object(forKey: key) ?? ""
    }
    
    func checkUserDefault(key: String) -> Bool {
        
        
        let userDefaults  = UserDefaults.standard
        
        if userDefaults.object(forKey: key) != nil {
            return true
        }
        
        return false
        
        //        let flag = UserDefaults.standard.objectIsForced(forKey: key)
        //        print(flag)
        //
        //        return flag
    }
    
    
    
    static func cleanJsonToObject(data : AnyObject) -> AnyObject{
        
        
        let jsonObjective : Any = data
        
        
        
        
        
        if jsonObjective is NSArray {
            
            //            let array : NSMutableArray = (jsonObjective as AnyObject) as! NSMutableArray
            
            let jsonResult : NSArray = (jsonObjective as? NSArray)!
            
            
            
            let array: NSMutableArray = NSMutableArray(array: jsonResult)
            
            
            
            //            for (int i = (int)array.count-1; i >= 0; i--)
            for  i in stride(from: array.count-1, through: 0, by: -1)
            {
                let a : AnyObject = array[i] as AnyObject;
                
                if a as! NSObject == NSNull(){
                    array.removeObject(at: i)
                    
                } else {
                    array[i] = UtilityClass.cleanJsonToObject(data: a)
                    
                    //                        [self cleanJsonToObject:a];
                }
            }
            return array;
        } else
            if jsonObjective is NSDictionary  {
                
                let jsonResult : Dictionary = (jsonObjective as? Dictionary<String, AnyObject>)!
                
                
                
                let dictionary: NSMutableDictionary = NSMutableDictionary(dictionary: jsonResult)
                
                //            let dictionary : NSMutableDictionary = (jsonResult as? NSMutableDictionary<String, AnyObject>)!
                
                for  key in dictionary.allKeys {
                    
                    let  d : AnyObject = dictionary[key as! NSCopying]! as AnyObject
                    
                    if d as! NSObject == NSNull()
                    {
                        dictionary[key as! NSCopying] = ""
                    }
                    else
                    {
                        dictionary[key as! NSCopying] = UtilityClass.cleanJsonToObject(data: d )
                    }
                }
                return dictionary;
            }
            else {
                return jsonObjective as AnyObject;
        }
    }
    
    
    class func getPath(fileName: String) -> String {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
       
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        print("========== DB Path \n \(fileURL) \n ===============")
        return fileURL.path
    }
    
    
    class func copyFile(fileName: NSString) {
        let dbPath: String = getPath(fileName: fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            let documentsURL = Bundle.main.resourceURL
            
             let fromPath = documentsURL?.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath!.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }

            print("===\n\(String(describing: error?.localizedDescription)) \nYour database copy successfully\n ====")

//            let alert: UIAlertView = UIAlertView()
//            if (error != nil) {
//                alert.title = "Error Occured"
//                alert.message = error?.localizedDescription
//            } else {
//                alert.title = "Successfully Copy"
//                alert.message = "Your database copy successfully"
//            }
//            alert.delegate = nil
//            alert.addButton(withTitle: "Ok")
//            alert.show()
        }
    }
  
}
