//
//  HostHistory.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import SVProgressHUD

class HostHistoryVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    static var cellIndentifire = "EventCell"
    
    @IBOutlet weak var table: UITableView?
    var arrayUpcomingEvent = NSArray()
    var arrayPastEvent = NSArray()
    @IBOutlet weak var segment: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        addNotificationButton()
        table?.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: HostHistoryVC.cellIndentifire)
        
        self.title = "Historial de anfitrión"
        // Do any additional setup after loading the view.
        
        getEventList()
    }


    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
    }

    
    // MARK:
    // MARK: GET event List
    func getEventList()
    {
        SVProgressHUD.show(withStatus: "por favor espera...")
        APIModal().myEvent(type: "C", time: "future", target: self, action: #selector(getFutureEventListHandle(response:)))
        
        APIModal().myEvent(type: "C", time: "past", target: self, action: #selector(getPastEventListHandle(response:)))
        
        
    }
    
    
    // MARK: Future Event List handle:
    func getFutureEventListHandle(response: AnyObject)
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
            arrayUpcomingEvent = jsonResult["data"] as! NSArray
            if(segment.selectedSegmentIndex == 0)
            {
                DispatchQueue.main.async{
                    self.table?.reloadData()
                }
            }
            
            
        }
    }
    
    
    
    
    // MARK: Past Event List handle:
    func getPastEventListHandle(response: AnyObject)
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
            arrayPastEvent = jsonResult["data"] as! NSArray
            if(segment.selectedSegmentIndex == 1)
            {
                DispatchQueue.main.async{
                    self.table?.reloadData()
                }
            }
            
            
        }
    }
    
    
    
    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(segment.selectedSegmentIndex == 0)
        {
            return arrayUpcomingEvent.count
        }
        else
        {
            return arrayPastEvent.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = HostHistoryVC.cellIndentifire
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! EventCell
        
        var dic: NSDictionary!
        if(segment.selectedSegmentIndex == 0)
        {
            dic =  arrayUpcomingEvent [indexPath.row] as! NSDictionary
        }
        else
        {
            dic =  arrayPastEvent [indexPath.row] as! NSDictionary
        }
        
//        let dic =  arrayUpcomingEvent [indexPath.row] as! NSDictionary
        
        cell.lblName?.text = dic.value(forKey: "title") as! String?
        
        let price = dic.value(forKey: "price") as! String
        
        if (price as NSString).doubleValue == 0
        {
            cell.btnPrice?.setTitle("Gratis", for: UIControlState.normal)
        }
        else
        {
            cell.btnPrice?.setTitle("$\(price)", for: UIControlState.normal)
        }
        
        
//        if(mapStruct.currentLocation !=  nil)
//        {
            let coordinate₀ = CLLocation(latitude:(dic.value(forKey: "latitude") as! NSString).doubleValue, longitude: (dic.value(forKey: "longitude") as! NSString).doubleValue)
        
        var coordinate₁  = CurrentLocation.location
        if(coordinate₁ == nil)
        {
            coordinate₁ = comman().getCurrentLocation()
        }
        
//            let coordinate₁ = CurrentLocation.location!
        
            let distanceInMeters = coordinate₀.distance(from: coordinate₁!) // result is in meters
            
            
            cell.lblDistance?.text = String(format:"%.2f km", distanceInMeters/1000.0)
//        }
//        else
//        {
//            cell.lblDistance?.text = "0 km"
//        }

        
        // set age ratio
        let female = dic.value(forKey: "femaleCount") as! Float
        let male = dic.value(forKey: "maleCount") as! Float
        
        
        if(female>0 || male>0)
        {
            let percentageFemale = ((female/(female+male))*100)
            
            let percentageMale = (male/(female+male)*100)
            
            cell.lblFeMalePercent.text = String(format:"%.f%%", percentageFemale)
            
            cell.lblMalePercent.text =  String(format:"%.f%%", percentageMale)
            
            cell.progressView?.progress = percentageFemale/100.0
            
        }
        else
            
        {
            cell.lblFeMalePercent.text = "0%"
            
            cell.lblMalePercent.text =  "0%"
            cell.progressView?.progress = 0.0
        }
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateString = dic.value(forKey: "heldon") as! String
        
        let timeString = dic.value(forKey: "starttime") as! String
        
        let earlierDate = dateFormatter.date(from: "\(dateString) \(timeString)")
        
        if(earlierDate != nil)
        {
            var interval: NSMutableAttributedString!
            
            if(segment.selectedSegmentIndex == 0)
            {
                interval = comman().daysBetweenDates(startDate: Date(), endDate: earlierDate!, type:"host")
            }
            else
            {
                interval = comman().dayTimeBetweenDates(startDate: Date(), endDate: earlierDate!)
            }
            
            //let interval: NSMutableAttributedString = comman().daysBetweenDates(startDate: Date(), endDate: earlierDate!)
            cell.lblTime?.attributedText = interval
        }
        
        cell.profileImage?.sd_setImage(with: URL.init(string: dic.value(forKey: "createrpic") as! String), placeholderImage: UIImage.init(named: "profile_pic"), options:SDWebImageOptions.retryFailed)
        
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height/2
        cell.profileImage.layer.borderWidth = 1
        cell.profileImage.layer.masksToBounds = true
        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 87.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let eventDetail: EventDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC

        var dic: NSDictionary!
        if(segment.selectedSegmentIndex == 0)
        {
            dic =  arrayUpcomingEvent [indexPath.row] as! NSDictionary
            eventDetail.eventVisitType = "future"
        }
        else
        {
            dic =  arrayPastEvent [indexPath.row] as! NSDictionary
            eventDetail.eventVisitType = "past"
        }


        eventDetail.dicEventDetail = dic
        
        self.navigationController?.pushViewController(eventDetail, animated: true)
        
        
    }
    
    
    @IBAction func segmentChangeTap(sender: UISegmentedControl)
    {
        DispatchQueue.main.async{
            self.table?.reloadData()
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
