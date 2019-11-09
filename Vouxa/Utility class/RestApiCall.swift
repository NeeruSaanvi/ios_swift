//
//  RestApiCall.swift
//  MOCSwift
//
//  Created by Piyush Agarwal on 9/22/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit

//import AFNetworking



class RestApiCall: NSObject {
    
    var action : Selector?
    var handler : AnyObject?
    
//    override init() {
//        self.action = nil
//        self.handler = nil
////
//    }
    
//    override init() {
//
//    }
    
//    init( target : AnyObject, action : Selector ){
//        
//        self.handler=target
//        self.action=action
//        // perform some initialization here
//    }
    
   func createRequest ( target : AnyObject, action1 : Selector ) ->RestApiCall  {
        
        let restRequest : RestApiCall = RestApiCall()
        
        restRequest.handler=target
        restRequest.action=action1
        
        return restRequest
    }
    
    
    func APiCall(prams : String , ApiName : String, ApiType: String, withClassRefrence: RestApiCall) {

        var url1 = utilityObject.baseUrl + ApiName

        if(ApiType.uppercased() == "GET")
        {
            url1 = url1 + "\(prams)"
        }


            let request = NSMutableURLRequest(url: NSURL(string: url1)! as URL) // Here kDataURL is the marco for URL.

            let session = URLSession.shared

            request.httpMethod = ApiType.uppercased()


        if(ApiType.uppercased() != "GET")
        {
            request.httpBody = prams.data(using: .utf8)
        }

            if(UtilityClass().checkUserDefault(key: "userinfo"))
            {


                let password : String = "123456"

                let facebookid = (UtilityClass().getUserDefault(key: "userinfo") as!NSDictionary).value(forKey: "facebookid") as! String


                let loginString = String(format: "%@:%@", facebookid, password)
                let loginData = loginString.data(using: String.Encoding.utf8)!
                let base64LoginString = loginData.base64EncodedString()

                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

            }


            
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            print("_____________________\n\n\n\n\n\nURL: \(String(describing: request.url))  \nRequest parameter: \(prams)\n\n\n\n===================")

            session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                

                 if error == nil
                 {
                do{
                    let strData = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)

                    print("========================\n\n\nURL: \(String(describing: response?.url)) \n\nResponse: \(strData) \n\n\n\nError: \(error)\n\n\n===================/")


                    let strData1 = UtilityClass.cleanJsonToObject(data: strData as AnyObject)
                    
                    if ((self.handler?.responds(to: self.action)) != nil)
                    {
//                        self.resposeHandler(response: strData1, withObject: withClassRefrence)
                        
//                        self.handler?.selector:self.action
                        
                        self.handler?.perform(self.action!, with:strData1)
                        
//                        Timer.scheduledTimer(timeInterval: 0.01, target: self.handler!, selector: self.action!, userInfo: strData1, repeats: false)
                    }
                    
                    print("Response: \(strData1)")
                }
                catch
                {
                    let dstString: String = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                    
                    let dic = self.convertToDictionary(text: dstString)
//                    [NSString stringWithUTF8String:[data bytes]]
                    if(dic != nil)
                    {
                        self.resposeHandler(response: dic as AnyObject, withObject: withClassRefrence)
                    }
                    else
                    {
                        self.resposeHandler(response: [:] as AnyObject, withObject: withClassRefrence)
                    }
                    
                    
//                    Timer.scheduledTimer(timeInterval: 0.0001, target: self.handler!, selector: self.action!, userInfo: [:], repeats: false)
                    print("Error info: \(error)")
                }
                }
                else
                 {
                    if ((self.handler?.responds(to: self.action)) != nil)
                    {
                        self.resposeHandler(response: [:] as AnyObject, withObject: withClassRefrence)
                        
                        
//                        Timer.scheduledTimer(timeInterval: 0.0001, target: self.handler!, selector: self.action!, userInfo: [:], repeats: false)
                    }
                }
                
                
                
                
            }).resume()
            
            //        var task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            //            // println(“Response: \(response)”)
            //            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //            println("Body: \(strData)")
            //
            //            var err: NSError?
            //            var json2 = NSJSONSerialization.JSONObjectWithData(strData.dataUsingEncoding(NSUTF8StringEncoding), options: .MutableLeaves, error:&err1 ) as NSDictionary
            //
            //            println("json1\(json2)")
            //        });
            
            
//        }
//        catch
//        {
//            print("Error info: \(error)")
//        }

    }
    
  
    func resposeHandler(response: AnyObject, withObject: RestApiCall)
    {
//        if(withObject.handler != nil && withObject.action != nil)
//        {
        
//            withObject.handler!.action!(response)
            
             Timer.scheduledTimer(timeInterval: 0.0001, target: self.handler!, selector: self.action!, userInfo: response, repeats: false)
//        }
       
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
}



/*
 
 func getAPiCall(prams : NSDictionary , ApiName : NSString ) {
 
 //        var manager : AFHTTPSessionManager
 let manager = AFHTTPSessionManager()
 manager.requestSerializer=AFJSONRequestSerializer()
 
 let url = utilityObject.baseUrl + (ApiName as String)
 
 let loginId: NSString=""
 
 let tokenId : NSString = "";
 
 //        NSDictionary *dicUser= [[NSUserDefaults standardUserDefaults] objectForKey:@"userinfo"];
 //
 //
 //        if(dicUser==nil)
 //        {
 //            dicUser=[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoDoc"];
 //        }
 //
 //
 //        if(dicUser!=nil)
 //        {
 //            loginId=[dicUser objectForKey:@"LoginId"];
 //            tokenId=[dicUser objectForKey:@"Token"];
 //        }
 //
 //
 
 print("_____________________\n\n\nLoginID: \(loginId)\n\nTokenId: \(tokenId)\n\n\nURL: \(url)  \nRequest parameter: \(prams)\n\n\n\n===================")
 
 
 //
 //
 //
 
 //    NSString *timeZoneName = [[NSTimeZone localTimeZone] name];
 
 manager.requestSerializer .setValue(loginId as String, forHTTPHeaderField: "userid")
 
 manager.requestSerializer .setValue(tokenId as String, forHTTPHeaderField: "token")
 
 manager.requestSerializer .setValue("" as String, forHTTPHeaderField: "timezone")
 
 manager.requestSerializer .setValue("" as String, forHTTPHeaderField: "timezonevalue")
 
 
 manager.requestSerializer.timeoutInterval=160
 
 
 //        manager.post(url as String, parameters: prams, progress: { (progress) in
 //
 //            }, success: { (task: URLSessionDataTask, responseObject: AnyObject) in
 //
 //            }, failure: {(task : URLSessionDataTask?, error : NSError) in
 //
 //                print("========================\n\n\nURL: \(url) \n\nError: \n\n\n===================\(error)")
 //
 //
 //                if ((self.handler?.responds(to: self.action)) != nil)
 //                {
 //                    Timer.scheduledTimer(timeInterval: 0.0001, target: self.handler!, selector: self.action!, userInfo: task, repeats: false)
 //                }
 //
 //        });
 //
 
 manager.get(url as String, parameters: prams, progress: { (progress) in
 
 }, success: { (task,responseObject) in
 
 print("========================\n\n\nURL: \(url) \n\nResponse: \(responseObject)\n\n\n===================/")
 
 
 let responceObj = UtilityClass().cleanJsonToObject(data: responseObject as AnyObject)
 
 
 if ((self.handler?.responds(to: self.action)) != nil)
 {
 
 Timer.scheduledTimer(timeInterval: 0.0001, target: self.handler!, selector: self.action!, userInfo: responceObj, repeats: false)
 }
 
 
 
 
 }, failure: {(task , error) in
 
 print("========================\n\n\nURL: \(url) \n\nError: \(error)\n\n\n===================")
 
 
 if ((self.handler?.responds(to: self.action)) != nil)
 {
 Timer.scheduledTimer(timeInterval: 0.0001, target: self.handler!, selector: self.action!, userInfo: [ : ], repeats: false)
 }
 
 });
 
 }
 
 */
