//
//  MapVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

struct mapStruct {
//    static var currentLocation : CLLocation!
    static var arrayEventList = NSArray()
    
    static var sliderAgeStr: Float = 0
    static var sliderDistanceStr: Float = 0
    static var sliderPriceStr: Float = 0
    static var btnDateStr: String = "0000-00-00"
//    static var lblMaxPriceStr: String = "1000"
//    static var lblMaxDistanceStr: String = "10000"
//    static var lblMaxAgeStr: String = "99"

}


class MapVC: BaseViewController,GMSAutocompleteResultsViewControllerDelegate, UISearchControllerDelegate, MKMapViewDelegate, BadgeClassDelegate {

    //location manager
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.requestWhenInUseAuthorization()
        _locationManager.activityType = .automotiveNavigation
        _locationManager.distanceFilter = kCLDistanceFilterNone  // Movement threshold for new events
        //  _locationManager.allowsBackgroundLocationUpdates = true // allow in background

        return _locationManager
    }()


    @IBOutlet weak var mapView: MKMapView!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var arrayAnnotations = [MKAnnotation]()

    var getListAPIFlag = 1;
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

//        let locManager = CLLocationManager()
//        locManager.requestWhenInUseAuthorization()
//        
//        var currentLocation1 = CLLocation()
//        
//        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//            CLLocationManager.authorizationStatus() == .authorizedAlways){
//            
//            currentLocation1 = locManager.location!
//            
//        }
        
        
//        locationManager.delegate = self;
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation() // start location manager
//
//        }


        let dicUser : NSDictionary = UtilityClass().getUserDefault(key: "userinfo") as! NSDictionary


        let password = dicUser.value(forKey: "facebookid") as! String + "123456"

        let loginUsername = (dicUser.value(forKey: "facebookid") as! String)

        SVProgressHUD.show(withStatus: "por favor espera...")

        ServiceClass.sharedInstance.login(userLogin: loginUsername, password: password, completion: { (response, success) in

            SVProgressHUD.dismiss()

            if(success)
            {
                let paramter = QBUpdateUserParameters()

                paramter.customData = dicUser.value(forKeyPath: "profilepic") as? String

                paramter.fullName = dicUser.value(forKeyPath: "name") as? String

                QBRequest.updateCurrentUser(paramter, successBlock: { (response, updatedUser) in

                    print("update Profile in quickblox")
                    print("\(String(describing: updatedUser))")

                }, errorBlock: { (response) in
                    print("\(String(describing: response.error))")
                })
            }
            else
            {

            }
        })



        BadgeClass.instance.deletgate = self
        
        mapView.delegate = self
        addSlideMenuButton()
        addNotificationButton()

//        if(locationManager.location != nil)
//        {
//            CurrentLocation.location = comman().getCurrentLocation()
//            self.gotoLocation(location: CurrentLocation.location)
//        }

        /////////
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: view.frame.size.width, height: 45.0))
        
        searchController?.searchBar.placeholder = "buscar"
        
        searchController?.searchBar.setValue("cancelar", forKey:"_cancelButtonText")

        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {

        //allow location use
//        locationManager.requestAlwaysAuthorization()

        print("did load")
//        print(locationManager)

        //get current user location for startup
         if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
         }

        if(getListAPIFlag == 0)
        {
            gotoLocationAndGetEvent();
        }

//        let location = comman().getCurrentLocation()
//            self.getEventList(lat:location.coordinate.latitude, long: location.coordinate.longitude )

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
    }
    // MARK:
    // MARK: GET event List
    func getEventList(lat: CLLocationDegrees, long: CLLocationDegrees)
    {
        APIModal().eventList(price: "\(mapStruct.sliderPriceStr)", distance: "\(mapStruct.sliderDistanceStr)", age: "\(mapStruct.sliderAgeStr)", date: mapStruct.btnDateStr, lat: "\(lat)", lng: "\(long)", pageno: "0", target: self, action: #selector(MapVC.getEventListHandle(response:)))
    
    }
    
    
    // MARK: Event List handle:
    func getEventListHandle(response: AnyObject)
    {
        let jsonResult : Dictionary = (response as? Dictionary<String, AnyObject>)!
        
        if (jsonResult["error"]as! Bool) == true
        {
            mapStruct.arrayEventList = NSArray()

            let alert = UIAlertController(title: "alerta", message: jsonResult["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            DispatchQueue.main.async{
            self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            mapStruct.arrayEventList = jsonResult["data"] as! NSArray
        }


        DispatchQueue.main.async{

            self.mapView.removeAnnotations(self.arrayAnnotations)

            var i = 0

            for item in  mapStruct.arrayEventList {


                let obj = item as! NSDictionary

                let latitude = (obj["latitude"] as! NSString).doubleValue
                let longitude = (obj["longitude"] as! NSString).doubleValue

                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                let annotation = CustomAnnotation (coordinate: coordinate)

                annotation.tag = i
                annotation.pinDetails = obj

                self.mapView.addAnnotation(annotation)

                self.arrayAnnotations.append(annotation)

                i = i+1
            }
        }
    }
    
    
    // MARK: auto complete delegates
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        //        print("Place name: \(place.name)")
        //        print("Place address: \(place.formattedAddress)")
        //        print("Place attributions: \(place.attributions)")


        let location: CLLocation = CLLocation.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.gotoLocation(location: location)
        
        getEventList(lat:place.coordinate.latitude, long: place.coordinate.longitude )
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    

    //MARK:
    // MARK: Map move current location on button click


//    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
//    {
//        CurrentLocation.location = manager.location!
//
//        let location = manager.location!
//
//        self.gotoLocation(location: location)
//
//        self.getEventList(lat: location.coordinate.latitude, long: location.coordinate.longitude )
//    }
//
//
//    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
//    {
//
//    }
//
//    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .authorizedWhenInUse:
//            manager.startUpdatingLocation()
//            break
//        case .authorizedAlways:
//            manager.startUpdatingLocation()
//            break
//        case .denied:
//            //handle denied
//            break
//        case .notDetermined:
//            manager.requestWhenInUseAuthorization()
//            break
//        default:
//            break
//        }
//    }
//    
//

    // Add a UIButton in Interface Builder, and connect the action to this function.
    @IBAction func getCurrentPlace(_ sender: UIButton) {


//        let location = comman().getCurrentLocation()

        gotoLocationAndGetEvent()
    }


    func gotoLocationAndGetEvent()
    {
        var location  = CurrentLocation.location
        if(location == nil)
        {
            location = comman().getCurrentLocation()
        }
        
        self.gotoLocation(location: location!)

        self.getEventList(lat: (location?.coordinate.latitude)!, long: (location?.coordinate.longitude)! )
    }

    func gotoLocation(location: CLLocation)
    {
        //        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
        
        mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("viewForAnnotation \(String(describing: annotation.title))")

        if !(annotation is CustomAnnotation) {
            return nil
        }

        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        
        let customAnnotation = annotation as! CustomAnnotation
        
        if((customAnnotation.pinDetails.value(forKey: "price") as! NSString).doubleValue == 0)
        {
            annotationView?.image = UIImage(named:"locationPinWithoutShadow")
        }
        else
        {
            annotationView?.image = UIImage(named:"locationPinWithoutShadow_paid")
        }
        
        
        return annotationView
    }
    

    
    
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        
//        if view.isKind(of: AnnotationView.self)
//        {
//            for subview in view.subviews
//            {
//                subview.removeFromSuperview()
//            }
//        }
        
        
        let customAnnotation = view.annotation as! CustomAnnotation
        
        // 2
//        let starbucksAnnotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("CustomCallout", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCallout

        let dic : NSDictionary = customAnnotation.pinDetails


        calloutView.lblName.text = "\(dic["title"] as! String)"

        // set price
        let price = dic.value(forKey: "price") as! String

        if (price as NSString).doubleValue == 0
        {
            calloutView.btnPrice.setTitle("Gratis", for: UIControlState.normal)
        }
        else
        {
            calloutView.btnPrice.setTitle("$\(price)", for: UIControlState.normal)
        }

        // end price


        // set age ratio
        let female = dic.value(forKey: "femaleCount") as! Float
        let male = dic.value(forKey: "maleCount") as! Float


        if(female>0 || male>0)
        {
            let percentageFemale = ((female/(female+male))*100)

            let percentageMale = (male/(female+male)*100)


            calloutView.lblFemaleAgePercentage.text = String(format:"%.f%%", percentageFemale)

            calloutView.lblMaleAgePercentage.text =  String(format:"%.f%%", percentageMale)




            calloutView.progressBar.progress = percentageFemale/100.0

        }
        else

        {
            calloutView.lblFemaleAgePercentage.text = "0%"

            calloutView.lblMaleAgePercentage.text =  "0%"
            calloutView.progressBar.progress = 0.0
        }


        // set date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateString = dic.value(forKey: "heldon") as! String

        let timeString = dic.value(forKey: "starttime") as! String

        let earlierDate = dateFormatter.date(from: "\(dateString) \(timeString)")

        let interval: NSMutableAttributedString = comman().daysBetweenDates(startDate: Date(), endDate: earlierDate!, type:"map")


       // dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"

        //calloutView.lblDate.text = "Fecha: \(dateFormatter.string(from: earlierDate!) as String)"

        calloutView.lblDate.attributedText = interval

        // end date

        // profile pic
        calloutView.imgProfile.sd_setImage(with: URL.init(string: dic.value(forKey: "createrpic") as! String), placeholderImage: UIImage.init(named: "profile_pic"))


        calloutView.imgProfile.layer.cornerRadius = calloutView.imgProfile.frame.size.height/2
        calloutView.imgProfile.layer.borderWidth = 1
        calloutView.imgProfile.layer.masksToBounds = true

        // end profile pic

        if(Int(dic["duration"] as! String) == 1)
        {
            calloutView.lblDuration.text = "Duracion: \(dic["duration"] as! String) hora"
        }
        else{
            calloutView.lblDuration.text = "Duracion: \(dic["duration"] as! String) horas"
        }
        //calloutView.lblDuration.text = "Duracion: \(dic["duration"] as! String) horas"

        let button = UIButton(frame: calloutView.frame)
        button.addTarget(self, action: #selector(self.tapOnCalloutView(sender:)), for: .touchUpInside)
        button.tag = customAnnotation.tag
        calloutView.addSubview(button)
        // 3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        
        calloutView.layer.cornerRadius = 15
        calloutView.layer.shadowRadius = 25
        calloutView.layer.shadowOffset = CGSize.init(width: calloutView.frame.size.width+10, height: calloutView.frame.size.height + 10)
        calloutView.layer.borderWidth = 1;
        view.addSubview(calloutView)
        
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
        
    }
    
    func tapOnCalloutView(sender: UIButton)
    {
        let eventInfo = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
        
        eventInfo.dicEventDetail = mapStruct.arrayEventList[sender.tag] as! NSDictionary
        
        eventInfo.eventVisitType = "eventList"
        
        self.navigationController?.pushViewController(eventInfo, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        let annotations = self.mapView.annotations
//        mapView.removeAnnotations(annotations)
//        mapView.addAnnotations(annotations)
    }
    

    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setBadge(count: Int)
    {
        if(tabBarController?.tabBar != nil)
        {
        let tabBar = (tabBarController?.tabBar)! as UITabBar
        let tabBarItem4 = tabBar.items![3] as UITabBarItem
        
        if(count != 0 )
        {
            if count > 99 {
                tabBarItem4.badgeValue  = "99+"
            } else {
                
                tabBarItem4.badgeValue  = String(format: "%d", count)
            }
        }
        else
        {
            tabBarItem4.badgeValue = nil
        }
            
        
        }
    }
    

    
    
    
}

// MARK: - CLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

//        for location in locations {

//            print("**********************")
//            print("Long \(location.coordinate.longitude)")
//            print("Lati \(location.coordinate.latitude)")
//            print("Alt \(location.altitude)")
//            print("Sped \(location.speed)")
//            print("Accu \(location.horizontalAccuracy)")
//
//            print("**********************")

            
//        }

        if(manager.location != nil)
        {
            CurrentLocation.location = manager.location!
        }

        if(getListAPIFlag == 1)
        {
            gotoLocationAndGetEvent();

            getListAPIFlag = 0;
        }

    }


        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
        {
            print(error.localizedDescription)

//                        CurrentLocation.location = comman().getCurrentLocation()
//                        self.gotoLocation(location: CurrentLocation.location)



//            gotoLocationAndGetEvent();

            if(getListAPIFlag == 1)
            {
                gotoLocationAndGetEvent();
                getListAPIFlag = 0;
            }

        }
    
        public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
                break
            case .authorizedAlways:
                manager.startUpdatingLocation()
                break
            case .denied:
                //handle denied
                break
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                break
            default:
                break
            }
        }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        self.locationManager.startUpdatingLocation()
    }
}



