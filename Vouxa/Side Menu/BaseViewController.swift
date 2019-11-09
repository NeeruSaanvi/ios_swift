//
//  BaseViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, SlideMenuDelegate,UITabBarControllerDelegate {

    var btnShowNotification : MIBadgeButton!

    var notificationViewController: NotificationVC!

//    var arrayRequestList = NSArray()

    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.delegate = self


        BadgeClass.instance.baseClassObjectArray.add(self)

//        BadgeClass.instance.deletgate = self
        BadgeClass.instance.getRequestList()

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        BadgeClass.instance.setBadgeCount()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32, withIdentifire: NSDictionary) {
//        let topViewController : UIViewController = self.navigationController!.topViewController!
//        print("View Controller is : \(topViewController) \n", terminator: "")
        if(index > -1 && withIdentifire.count>0)
        {
        self.openViewControllerBasedOnIdentifier(withIdentifire.object(forKey: "identifire") as! String)
        }
        
//        switch(index){
//        case 0:
////            print("Home\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("Home")
//            
//            break
//        case 1:
////            print("Play\n", terminator: "")
//            
//            self.openViewControllerBasedOnIdentifier("PlayVC")
//            
//            break
//        default:
//            print("default\n", terminator: "")
//        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(UIImage.init(named: "side menu 3 bar"), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
       
        return defaultMenuImage;
    }
    
    func onSlideMenuButtonPressed(_ sender : UIButton)
    {


        self.view.endEditing(true)
        self.navigationController?.view.endEditing(true)

//        MapVC().resultsViewController
        for view in self.view.subviews
        {
//            if(view .isKind(of: UISearchBar()))
//            {
//                let search = view as! UISearchController
//
//            }
            view.endEditing(true)
        }

        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1, withIdentifire: [:]);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            }, completion:nil)
    }
    
    
    
    // Mark: Add notifiacation on navigationbar
    
    func addNotificationButton(){


        btnShowNotification = MIBadgeButton(type: UIButtonType.custom)

//        btnShowNotification = MIBadgeButton.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

        btnShowNotification.setImage(UIImage.init(named: "notification bell"), for: UIControlState.normal)
        btnShowNotification.setImage(UIImage.init(named: "notification bell_selected"), for: UIControlState.selected)
        
        
        btnShowNotification.frame = CGRect(x: 0, y: 0, width: 60, height: 44)

        
        btnShowNotification.addTarget(self, action: #selector(BaseViewController.onNotificationButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        btnShowNotification.transform = CGAffineTransform(translationX: 20, y: 0)


        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: btnShowNotification.frame)
        suggestButtonContainer.addSubview(btnShowNotification)
        
        
        let customBarItem = UIBarButtonItem(customView: suggestButtonContainer)
//        customBarItem.width = -20;
//        customBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)
   //     customBarItem
        btnShowNotification.badgeTextColor = UIColor.white
        btnShowNotification.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 15)

        self.navigationItem.rightBarButtonItem = customBarItem;
        
//        self.navigationItem.rightBarButtonItem.setImageInsets:UIEdgeInsetsMake(10, 0, 0, 50)
        
    }

    
    func onNotificationButtonPressed(_ sender : UIButton){
        
       self.view.resignFirstResponder()
        
        
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there

           
            sender.isSelected = false
            sender.backgroundColor=nil;
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.y = -1 * UIScreen.main.bounds.size.height
                
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        sender.backgroundColor=UIColor.white;
        
        sender.isSelected = true
        
//        sender.setImage(UIImage.init(named: "Cross"), for: UIControlState())
        


//        if(notificationViewController == nil)
//        {
            notificationViewController = self.storyboard!.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
//            NotificationVC.instance

//        }

//

        self.view.addSubview(notificationViewController.view)

        self.addChildViewController(notificationViewController)
        notificationViewController.view.layoutIfNeeded()
        
//        notificationViewController.arrayPendingList = arrayRequestList

        notificationViewController.view.frame=CGRect(x: 0 , y: 0 - UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.notificationViewController.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
    }
    
    
    func closeNotificationScreen()
    {
        if(btnShowNotification.tag == 10)
        {
            onNotificationButtonPressed(btnShowNotification)
        }
    }



    func setNaviationBarBadge(count: Int) {

        btnShowNotification.badgeString =  String(format: "%d", count)
    }


    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {


        let navigation = viewController as! UINavigationController

        navigation.popToRootViewController(animated: true)
//        print("Selected view controller\(tabBarController.selectedIndex)")
    }
}
