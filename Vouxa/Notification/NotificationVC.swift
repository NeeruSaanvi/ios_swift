//
//  NotificationVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import SDWebImage

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView?
    var arrayPendingList = NSMutableArray()

    var buttonTag : Int!
//    static let instance = NotificationVC()

    override func viewDidLoad() {
        super.viewDidLoad()

        arrayPendingList = NSMutableArray.init(array: BadgeClass.instance.arrayRequestList)

        setBlankLabel()

        
//        getRequestList()
        // Do any additional setup after loading the view.
    }

    func setBlankLabel ()
    {
        if(arrayPendingList.count == 0)
        {
            table?.isHidden = true
            let lblMessage = UILabel.init(frame: CGRect.init(x: 0, y: self.view.frame.size.height/2, width: self.view.frame.size.width, height: 30))
            lblMessage.text = "Ningún record fue encontrado"
            
            lblMessage.textAlignment = NSTextAlignment.center
            
            self.view.addSubview(lblMessage)
        }
    }
    
    
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayPendingList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "NotificationTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationTableViewCell
        
        let dic: NSDictionary = arrayPendingList[indexPath.row] as! NSDictionary
        
        cell.lblName?.text = dic.value(forKey: "requestUserName") as! String?;
        
        let format : DateFormatter = DateFormatter()
        
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = format.date(from: (dic.value(forKey: "dateTime") as! String?)!)
        
        format.dateFormat = "dd/MM/yyyy hh:mm a"
        
        cell.lblDate?.text = format.string(from: date!)
        
        
        //cell.btnAccept?.layer.cornerRadius=5;
        cell.btnDecline?.layer.cornerRadius=5;
        cell.btnDecline?.layer.borderColor=utilityObject.mainColor.cgColor;
        cell.btnDecline?.layer.borderWidth=1;
        cell.btnAccept?.tag = indexPath.row
        cell.btnDecline?.tag = indexPath.row
        
        cell.btnAccept?.addTarget(self, action: #selector(acceptButtonClick(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.btnDecline?.addTarget(self, action: #selector(declineButtonClick(sender:)), for: UIControlEvents.touchUpInside)

        cell.imgProfile.sd_setImage(with: URL.init(string: dic.value(forKey: "requestUserProfilepic") as! String), placeholderImage: UIImage.init(named: "profile_pic"), options:SDWebImageOptions.retryFailed)

        cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height/2
        cell.imgProfile.layer.borderWidth = 1
        cell.imgProfile.layer.masksToBounds = true


        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 140.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == .delete) {

//        self.arrayPendingList.removeObject(at: self.buttonTag)
//        BadgeClass.instance.arrayRequestList.removeObject(at: self.buttonTag)
//
//        self.setBlankLabel()
//        BadgeClass.instance.setBadgeCount()

//    let LM_ITEM = lebensmittel[indexPath.row]
//    managedObjectContext?.deleteObject(lebensmittel[indexPath.row])
//    self.DatenAbrufen()

        //table?.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
//        table.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    }

   
    
    func acceptButtonClick(sender: UIButton)
    {//
        buttonTag = sender.tag
        SVProgressHUD.show(withStatus: "Por Favor Espero..")
        APIModal().processeventrequest(requestId: (arrayPendingList[sender.tag] as! NSDictionary).value(forKey: "requestId") as! String, isAccept: "1", target: self, action: #selector(requestAcceptDeclinehandle(response:)))
    }
    
    
    func declineButtonClick(sender: UIButton)
    {
        buttonTag = sender.tag
        SVProgressHUD.show(withStatus: "Por Favor Espero..")
        APIModal().processeventrequest(requestId: (arrayPendingList[sender.tag] as! NSDictionary).value(forKey: "requestId") as! String, isAccept: "0", target: self, action: #selector(requestAcceptDeclinehandle(response:)))
    }

    func requestAcceptDeclinehandle(response: AnyObject)
    {
        SVProgressHUD.dismiss()
        let jsonResult : Dictionary = (response as? Dictionary<String, AnyObject>)!
        
        if (jsonResult["error"]as! Bool) == true
        {
            let alert = UIAlertController(title: "alerta", message: jsonResult["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            DispatchQueue.main.async{
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            DispatchQueue.main.async{


//                self.txProtocols.removeObjectAtIndex(indexPath.row)

                let indexPath = IndexPath(item: self.buttonTag, section: 0)

                self.table?.beginUpdates()
                self.arrayPendingList.removeObject(at: self.buttonTag)
                BadgeClass.instance.arrayRequestList.removeObject(at: self.buttonTag)

                self.setBlankLabel()
                BadgeClass.instance.setBadgeCount()

                self.table?.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                self.table?.endUpdates()

//                if(self.arrayPendingList.count > self.buttonTag)
//                {
//                    self.table?.reloadRows(at: [indexPath], with: .top)
//                }
//
//                self.table?.reloadData()





//              BadgeClass.instance.getRequestList()
            }
        }
    }
    
    
//    func getRequestList()
//    {
//        APIModal().pendingrequests(target: self, action: #selector(getRequestListHandle(response:)))
//        
//        
//        //                   APIModal().joinevent(eventid: dicEventDetail["id"] as! String, target: self, action: #selector(getRequestListHandle(response:)))
//    }
//    
//    
//    func getRequestListHandle(response: AnyObject)
//    {
//        let jsonResult : Dictionary = (response as? Dictionary<String, AnyObject>)!
//        
//        self.arrayPendingList = NSArray()
//        
//        if (jsonResult["error"]as! Bool) == true
//        {
////            let alert = UIAlertController(title: "alerta", message: jsonResult["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
////            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
////            
////            DispatchQueue.main.async{
////                self.present(alert, animated: true, completion: nil)
////            }
//        }
//        else
//        {
//            self.arrayPendingList = jsonResult["data"] as! NSArray
//        }
//        
//        DispatchQueue.main.async{
//            self.table?.reloadData()
//        }
//
//        
//    }


    
    
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
