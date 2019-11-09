//
//  APIModal.swift
//  MOCSwift
//
//  Created by Piyush Agarwal on 9/23/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit



class APIModal: NSObject {


    // MARK LOGIN API 
    
    func loginUser(email: String, facebookid: String, dob: NSString, name: NSString, gender: NSString,contactno: NSString,profilepic: NSString, target: AnyObject, action: Selector) {

        profilepic.replacingOccurrences(of: "&", with: "%26")
        profilepic.replacingOccurrences(of: "=", with: "%3D")
        
//        let escapedString = profilepic.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as String
        
//        print(escapedString)

        
       
        
        
        
//        let devicetoken: Data = (UIApplication.shared.delegate as! AppDelegate).deviceToken as Data
//        devicetoken.base64EncodedData()

        
        if((UIApplication.shared.delegate as! AppDelegate).deviceToken == nil)
        {
            (UIApplication.shared.delegate as! AppDelegate).deviceToken = "flEB6LBj9Ko:APA91bGQHqCL-YsSKkWH-CPV_FWpG4W_UaduHlOsT4PlOLCNNpecmX3-7DIZwfooEy0TDcg21BK9rNaonUuSrVkPI_o0pO4uITP75JcVWr6XkP4Pqq1mcdZ165d41CjStNvRVJk8yDhb"
        }
        
        let params : String = "email=\(email)&facebookid=\(facebookid)&name=\(name)&deviceid=\(UIDevice.current.identifierForVendor!.uuidString)&devicetoken=\((UIApplication.shared.delegate as! AppDelegate).deviceToken as String )&devicetype=I&gender=\(gender)&dob=\(dob)&profilepic=\(profilepic)&contactno=\(contactno)"

        print(params)

        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)
        
        restapi.APiCall(prams: params, ApiName: "registeration", ApiType: "post", withClassRefrence: restapi)
        
    }

    //MARK:
    // MARK: Add event API

    func addEvent(eventName: String, description: String, starttime: String, address: String, duration: String,price: String,capacity: String,maleage:String,femaleage:String,heldon:String,latitude:String,longitude: String, groupId: String, target: AnyObject, action: Selector) {

        let params : String = "title=\(eventName)&description=\(description)&address=\(address)&latitude=\(latitude)&longitude=\(longitude)&heldon=\(heldon)&starttime=\(starttime)&duration=\(duration)&price=\(price)&capacity=\(capacity)&maleage=\(maleage)&femaleage=\(femaleage)&groupId=\(groupId)"

        print(params)

        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)

        restapi.APiCall(prams: params, ApiName: "event", ApiType: "post", withClassRefrence: restapi)
        
    }

    //MARK:
    // MARK: GET EVENT LIST  API

    func eventList(price: String, distance: String, age: String, date: String, lat: String, lng: String, pageno: String, target: AnyObject, action: Selector) {

        let params : String = "/\(price)/\(distance)/\(age)/\(date)/\(lat)/\(lng)/\(pageno)"

        print(params)

        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)

        restapi.APiCall(prams: params, ApiName: "eventlist", ApiType: "get", withClassRefrence: restapi)
        
    }

    //MARK:
    // MARK: GET MY EVENT LIST  API

    // time = past -> for Past Events, future -> For future events, ALL -> All events
    
    
    func myEvent(type: String, time: String, target: AnyObject, action: Selector) {

        let params : String = "/\(type)/\(time)"

        print(params)

        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)

        restapi.APiCall(prams: params, ApiName: "myevent", ApiType: "get", withClassRefrence: restapi)
        
    }
    
    
    
    //MARK:
    // MARK: join event API
    
    func joinevent(eventid: String, target: AnyObject, action: Selector) {
        
        let params : String = "eventid=\(eventid)"
        
        print(params)
        
        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)
        
        restapi.APiCall(prams: params, ApiName: "joinevent", ApiType: "post", withClassRefrence: restapi)
        
    }
    
    //MARK:
    // MARK: pending requests List API
    
    func pendingrequests(target: AnyObject, action: Selector) {
        
        let params : String = ""
        
        print(params)
        
        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)
        
        restapi.APiCall(prams: params, ApiName: "pendingrequests", ApiType: "get", withClassRefrence: restapi)
        
    }
    
    //MARK:
    // MARK: process event request API
    
    func processeventrequest(requestId: String, isAccept: String, target: AnyObject, action: Selector) {
        
        let params : String = "requestId=\(requestId)&isAccept=\(isAccept)"
        
        print(params)
        
        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)
        
        restapi.APiCall(prams: params, ApiName: "processeventrequest", ApiType: "post", withClassRefrence: restapi)
        
    }
    
    
    //MARK:
    // MARK: process event request API
    
    func eventattendies(eventid: String, target: AnyObject, action: Selector) {
        
        let params : String = "/\(eventid)"
        
        print(params)
        
        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)
        
        restapi.APiCall(prams: params, ApiName: "eventattendies", ApiType: "get", withClassRefrence: restapi)
        
    }
    
    //MARK:
    // MARK: process event request API
    
    func makepayment(eventid: String,token: String, amount: String , target: AnyObject, action: Selector) {
        
        let params : String = "eventid=\(eventid)&token=\(token)&amount=\(amount)"
        
        print(params)
        
        let restapi : RestApiCall = RestApiCall().createRequest(target: target, action1: action)
        
        restapi.APiCall(prams: params, ApiName: "makepayment", ApiType: "post", withClassRefrence: restapi)
        
    }

    
   }
