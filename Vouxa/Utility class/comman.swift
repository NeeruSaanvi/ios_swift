//
//  comman.swift
//  MOCSwift
//
//  Created by Piyush Agarwal on 11/23/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

struct CurrentLocation {
    static var location: CLLocation!

}

class comman: NSObject {

    
    // MARK: UIAlertView Comman Method
    
    func alertView(title: String, message: String, object: AnyObject, cancelTitle: String) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        object.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    
    // MARK: validate TextField
    func validateTextFiled(textfiled: UITextField) -> Bool {
        
        textfiled.text = textfiled.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if textfiled.text==nil || textfiled.text == ""
        {
            return false
        }
        
        return true
        
    }
    
    func validateEmailId(textfiled: UITextField) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: textfiled.text)
        
    }

    
    // MARK: Get Remaining Time
    func daysBetweenDates(startDate: Date, endDate: Date, type: String) -> NSMutableAttributedString {
        
        var size : CGFloat = 15;
        if(type == "map")
        {
            size = 11;
        }

        let Attributes1 = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.init(name: "Roboto-Regular", size: size)!] as [String : Any]
        
        let Attributes2 = [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.init(name: "Roboto-Regular", size: 13)!] as [String : Any]
        
        
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([Calendar.Component.minute], from: startDate, to: endDate)
        
      
        if components.minute! < 1
        {
            if(type == "map")
            {
                return NSMutableAttributedString(string: "Fecha: Ahora", attributes: Attributes1)
            }
            else
            {
            return NSMutableAttributedString(string: "Ahora", attributes: Attributes1)
            }
        }
        
        var remainingType: NSString?
        var remainingTime : String
        
        if components.minute! < 60
        {
            if (components.minute! > 1){
                remainingType = "Minutos"}
            else{
                remainingType = "Minuto"}
            
            remainingTime = "\(components.minute!)"
            //             components.minute!
        }
        else
        {
            components = calendar.dateComponents([Calendar.Component.hour], from: startDate, to: endDate)
            
            if components.hour! < 24
            {
                if (components.hour! > 1){
                    remainingType = "Horas"}
                else{
                    remainingType = "Hora"}
                
                remainingTime = "\(components.hour!)"
                
            }
            else
            {
                components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
                
                if components.day! <= 30
                {
                    if (components.day! > 1){
                        remainingType = "Días"}
                    else{
                        remainingType = "Día"}
                    remainingTime = "\(components.day!)"
                }
                else
                {
                    components = calendar.dateComponents([Calendar.Component.month], from: startDate, to: endDate)

                    if components.month! <= 12
                    {
                        if (components.month! > 1){
                            remainingType = "Meses"}
                        else{
                            remainingType = "Mes"}
                        remainingTime = "\(components.month!)"
                    }
                else
                {
                    components = calendar.dateComponents([Calendar.Component.year], from: startDate, to: endDate)
                    
                    if (components.year! > 1){
                        remainingType = "Años"}
                    else{
                        remainingType = "Año"}
                    
                    
                    remainingTime = "\(components.year!)"
                }
                }
            }
            
        }


        var partOne : NSAttributedString!

        if(type == "map")
        {
            partOne = NSAttributedString(string: "Fecha: en ", attributes: Attributes1)
        }
        else
        {
            partOne = NSAttributedString(string: "En\n", attributes: Attributes2)
        }
        
//        let partOne = NSAttributedString(string: "en\n", attributes: Attributes2)

        var  partTwo: NSAttributedString!

        if(type == "map")
        {
            partTwo = NSAttributedString(string: "\(remainingTime) ", attributes: Attributes1)
        }
        else
        {
            partTwo = NSAttributedString(string: "\(remainingTime)\n", attributes: Attributes1)
        }




        var  partthree: NSAttributedString!

        if(type == "map")
        {
            partthree = NSAttributedString(string: remainingType! as String , attributes: Attributes1)
        }
        else
        {
            partthree = NSAttributedString(string: remainingType! as String , attributes: Attributes2)
        }
        




        
        
//        let partTwo = NSAttributedString(string: "\(remainingTime)\n", attributes: Attributes1)

//        let partthree = NSAttributedString(string: remainingType as! String , attributes: Attributes2)

        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        combination.append(partthree)
        
        return combination
        
    }

    
    
    // MARK: Get past Time
    func dayTimeBetweenDates(startDate: Date, endDate: Date) -> NSMutableAttributedString {
        
        
        let Attributes1 = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.init(name: "Roboto-Regular", size: 15)!] as [String : Any]
        
        let Attributes2 = [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.init(name: "Roboto-Regular", size: 13)!] as [String : Any]
        
        
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([Calendar.Component.minute], from: endDate, to:startDate )
        
        
       
        var remainingType: NSString?
        var remainingTime : String
        
        if components.minute! < 60
        {
            if (components.minute! > 1){
                remainingType = "Minutos"}
            else{
                remainingType = "Minuto"}
            
            remainingTime = "\(components.minute!)"
            //             components.minute!
        }
        else
        {
            components = calendar.dateComponents([Calendar.Component.hour], from: endDate, to: startDate)
            
            if components.hour! < 24
            {
                if (components.hour! > 1){
                    remainingType = "Horas"}
                else{
                    remainingType = "Hora"}
                
                remainingTime = "\(components.hour!)"
                
            }
            else
            {
                components = calendar.dateComponents([Calendar.Component.day], from: endDate, to: startDate)
                
                if components.day! <= 30
                {
                    if (components.day! > 1){
                        remainingType = "Días"}
                    else{
                        remainingType = "Día"}
                    remainingTime = "\(components.day!)"
                }
                else
                {
                    components = calendar.dateComponents([Calendar.Component.month], from: endDate, to: startDate)
                    if components.month! <= 12
                    {
                        if (components.month! > 1){
                            remainingType = "Meses"}
                        else{
                            remainingType = "Mes"}
                        remainingTime = "\(components.month!)"
                    }
                    else
                {
                    components = calendar.dateComponents([Calendar.Component.year], from: endDate, to: startDate)
                    
                    if (components.year! > 1){
                        remainingType = "Años"}
                    else{
                        remainingType = "Año"}
                    
                    
                    remainingTime = "\(components.year!)"
                }
                }
            }
            
        }
        
        
        let partOne = NSAttributedString(string: "Hace\n", attributes: Attributes2)
       
        
        
        let partTwo = NSAttributedString(string: "\(remainingTime)\n", attributes: Attributes1)
        
        let partthree = NSAttributedString(string: remainingType! as String , attributes: Attributes2)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        combination.append(partthree)
        
        return combination
        
    }

    
    
    
    func getCurrentLocation() -> (CLLocation)
    {
//        DispatchQueue.main.async{

             let locationManager = CLLocationManager()

            if(CLLocationManager.locationServicesEnabled()) {
//                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()


                if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                    CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){

                    if((locationManager.location) != nil)
                    {
//                        CurrentLocation.location = locationManager.location

                        return locationManager.location!
                    }
                }
            }
            else {

            }

        //40.4637 3.7492 // spain
        // 26.9124 75.7873 // jaipur
        return CLLocation.init(latitude: 40.4637, longitude: 3.7492)
        }
//    }


    func calcAge(birthday:String) -> Int{
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let now: NSDate! = NSDate()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now as Date, options: [])
        let age = calcAge.year
        return age!
    }

}


public enum DisplayType {
    case unknown
    case iphone4
    case iphone5
    case iphone6
    case iphone6plus
    static let iphone7 = iphone6
    static let iphone7plus = iphone6plus
}

public final class Display {
    class var width:CGFloat { return UIScreen.main.bounds.size.width }
    class var height:CGFloat { return UIScreen.main.bounds.size.height }
    class var maxLength:CGFloat { return max(width, height) }
    class var minLength:CGFloat { return min(width, height) }
    class var zoomed:Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
    class var retina:Bool { return UIScreen.main.scale >= 2.0 }
    class var phone:Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    class var pad:Bool { return UIDevice.current.userInterfaceIdiom == .pad }
  
    class var typeIsLike:DisplayType {
        if phone && maxLength < 568 {
            return .iphone4
        }
        else if phone && maxLength == 568 {
            return .iphone5
        }
        else if phone && maxLength == 667 {
            return .iphone6
        }
        else if phone && maxLength == 736 {
            return .iphone6plus
        }
        return .unknown
    }
}


