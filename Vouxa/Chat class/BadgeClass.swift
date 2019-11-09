//
//  ServiceDelegates.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 1/6/17.
//  Copyright © 2017 Pinesucceed. All rights reserved.
//

import UIKit

@objc protocol BadgeClassDelegate {
    
    @objc optional func setBadge(count: Int)
    
//    @objc optional func setNaviationBarBadge(count: Int)

}



class BadgeClass: NSObject {
    var deletgate: BadgeClassDelegate! = nil
    static let instance = BadgeClass()
    var arrayRequestList = NSMutableArray()
    var baseClassObjectArray = NSMutableArray()


    func setBadgeonTabBar(count: Int)
    {
        if(deletgate != nil)
        {
            deletgate.setBadge!(count: count)
        }
    }



    func getRequestList()
    {

        APIModal().pendingrequests(target: self, action: #selector(getRequestListHandle(response:)))
    }


    func getRequestListHandle(response: AnyObject)
    {
        let jsonResult : Dictionary = (response as? Dictionary<String, AnyObject>)!

        self.arrayRequestList = NSMutableArray()

        if (jsonResult["error"]as! Bool) == true
        {

        }
        else
        {
//            if(self.notificationViewController != nil)
//            {
//
//                self.notificationViewController.arrayPendingList  = jsonResult["data"] as! NSArray
//
//
//            }

            //NotificationVC.instance.arrayPendingList  = jsonResult["data"] as! NSArray

            self.arrayRequestList = jsonResult["data"] as! NSMutableArray



        }

        DispatchQueue.main.async{

            self.setBadgeCount()
            
        }

        
    }


    func setBadgeCount()
    {
        for baseObj in baseClassObjectArray
        {
            //                baseObj = baseObj as! BaseViewController

            if((baseObj as! BaseViewController).notificationViewController != nil)
            {
                (baseObj as! BaseViewController).notificationViewController.table?.reloadData()
            }

            if( arrayRequestList.count>0)
            {
                ( baseObj as! BaseViewController).btnShowNotification.badgeString =  String(format: "%d", arrayRequestList.count)

            }
            else
            {
                ( baseObj as! BaseViewController).btnShowNotification.badgeString = nil
            }
        }

    }
    
}
