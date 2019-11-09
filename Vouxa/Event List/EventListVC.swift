//
//  EventListVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
//import sd_setImageWithURL
import SDWebImage

class EventListVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var table: UITableView?
    
    static var cellIndentifire = "EventCell"
    var arraySearch: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        addNotificationButton()
        table?.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: EventListVC.cellIndentifire)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        

//        let location = CurrentLocation.location!

        var location  = CurrentLocation.location
        if(location == nil)
        {
            location = comman().getCurrentLocation()
        }
        
            getEventList(lat: Float(location!.coordinate.latitude), long: Float(location!.coordinate.longitude))


    }

    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
    }

    
    // MARK:
    // MARK: GET event List
    func getEventList(lat: Float, long: Float)
    {
        
        APIModal().eventList(price: "\(mapStruct.sliderPriceStr)", distance: "\(mapStruct.sliderDistanceStr)", age: "\(mapStruct.sliderAgeStr)", date: mapStruct.btnDateStr, lat: "\(lat)", lng: "\(long)", pageno: "0", target: self, action: #selector(getEventListHandle(response:)))
        
        //         APIModal().myevent(type: "ALL", target: self, action: #selector(MapVC.getEventListHandle(response:)))
    }
    
    
    // MARK: Event List handle:
    func getEventListHandle(response: AnyObject)
    {
        let jsonResult : Dictionary = (response as? Dictionary<String, AnyObject>)!

        if (jsonResult["error"]as! Bool) == true
        {
            arraySearch = NSMutableArray()

            let alert = UIAlertController(title: "alerta", message: jsonResult["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            DispatchQueue.main.async{
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            mapStruct.arrayEventList = jsonResult["data"] as! NSArray
            
            arraySearch = NSMutableArray.init(array: mapStruct.arrayEventList)
        }


        DispatchQueue.main.async{
            self.table?.reloadData()
        }


    }

    
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arraySearch.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = EventListVC.cellIndentifire
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EventCell
        
        
        let dic: NSDictionary = arraySearch[indexPath.row] as! NSDictionary
        
        
        cell.lblName.text = dic.value(forKey: "title") as! String?
        
        let price = dic.value(forKey: "price") as! String
        
        if (price as NSString).doubleValue == 0
        {
            cell.btnPrice.setTitle("Gratis", for: UIControlState.normal)
        }
        else
        {
            cell.btnPrice.setTitle("$\(price)", for: UIControlState.normal)
        }
        
        cell.lblDistance.text = String(format:"%.2f km", dic.value(forKey: "distance") as! Float)
        
        
        
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
        
        
        //        let dateStr = String(format:"")
        let dateString = dic.value(forKey: "heldon") as! String
        
        let timeString = dic.value(forKey: "starttime") as! String
        
        let earlierDate = dateFormatter.date(from: "\(dateString) \(timeString)")

        if(earlierDate != nil)
        {
        let interval: NSMutableAttributedString = comman().daysBetweenDates(startDate: Date(), endDate: earlierDate!, type:"event")

        cell.lblTime.attributedText = interval
        }
        else
        {
            cell.lblTime.text = ""
        }


        cell.profileImage.sd_setImage(with: URL.init(string: dic.value(forKey: "createrpic") as! String), placeholderImage: UIImage.init(named: "profile_pic"), options:SDWebImageOptions.retryFailed)
        
        
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
        let eventInfo = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
        
        eventInfo.dicEventDetail = mapStruct.arrayEventList[indexPath.row] as! NSDictionary
        eventInfo.eventVisitType = "eventList"

        self.navigationController?.pushViewController(eventInfo, animated: true)
        
    }
    
    
    // MARK:
    // MARK: search in list
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        arraySearch .removeAllObjects()
        
        if(searchText == "")
        {
            arraySearch = NSMutableArray.init(array: mapStruct.arrayEventList)
        }
        else
        {
            for dic in mapStruct.arrayEventList
            {
                
                if ((((dic as! NSDictionary).value(forKey: "title") as! String).range(of: searchText, options: .caseInsensitive)) != nil)
                {
                    
                    arraySearch .add(dic)
                }
                
                
                //                (dic as! NSDictionary).value(forKey: "title") as! NSString;).NSRangeFromString(searchText)
                
                if((dic as! NSDictionary).value(forKey: "title") as! NSString).contains(searchText)
                {
                    
                }
                
                
            }
        }
        
        table?.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
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


