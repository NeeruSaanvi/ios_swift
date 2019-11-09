//
//  EventDetailsVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/6/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import Stripe.STPCardParams

class EventDetailsVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, STPAddCardViewControllerDelegate {


    var dicEventDetail : NSDictionary!
    var eventVisitType: String!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var colloactionView: UICollectionView!
    var arrMenu =  NSMutableArray()
    
    
    var arrayAttendees = NSArray()

    let dateType = "date"
    let addressType = "address"
    let descriptionType = "description"
    let priceType = "price"
    let durationType = "duration"
    let capacity = "capacity"
    let eventName = "eventname"
    let attendeesType = "attendees"

    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationButton()

        self.title = "Informacion"
        
        getAttendees()
        
        arrMenu.add(eventName)
        arrMenu.add(dateType)
        
        let str = (dicEventDetail.value(forKey: "description") as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
            
        if(str != "")
        {
            arrMenu.add(descriptionType)
        }
        
        arrMenu.add(addressType)
        arrMenu.add(durationType)
        
        
         let str1 = (dicEventDetail.value(forKey: "capacity") as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if(str1 != "0")
        {
            arrMenu.add(capacity)
        }
        
        
        arrMenu.add(priceType)
        arrMenu.add(attendeesType)
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
    }

    

    // MARK:
    // MARK: tableviuew delegates
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrMenu.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cellIdentifier = "cell1"
        if(arrMenu[indexPath.row] as! String == attendeesType)
        {
            cellIdentifier = "cell2"
        }

        //        let cell:EventDetailsInfo = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! EventDetailsInfo

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EventDetailsInfo

        if(arrMenu[indexPath.row] as! String == eventName)
        {
            cell.lbl1.text = dicEventDetail.value(forKey: "title") as? String

            cell.lbl1.textColor = utilityObject.mainColor
            cell.lbl1.font = UIFont.init(name: "Roboto-Regular", size: 30)
            cell.lbl1.textAlignment = NSTextAlignment.center

            cell.imgClock.isHidden = true
            cell.lbl2.isHidden = true
            cell.btnChatAndPrice.isHidden = true
        }
        else
            if(arrMenu[indexPath.row] as! String == dateType)
            {
                cell.constratentClockImageHeight.constant = 15;
                cell.imgClock.image = UIImage.init(named: "Clock")
                cell.btnWidthConstraint.constant = cell.btnWidthConstraint.constant-10

                cell.lbl1.isHidden = true
                cell.btnChatAndPrice .setTitle("Chatear", for: UIControlState.normal)
                cell.btnChatAndPrice.setImage(UIImage.init(named: "ChatIcon"), for: UIControlState.normal)
                let dateformat = DateFormatter()

                dateformat.dateFormat = "yyyy-MM-dd"
                let date = dateformat.date(from: dicEventDetail.value(forKey: "heldon") as! String)
                dateformat.dateFormat = "dd/MMM/yyyy"
                let dateStr = dateformat.string(from: date!)

                dateformat.dateFormat = "HH:mm:ss"
                let time = dateformat.date(from: dicEventDetail.value(forKey: "starttime") as! String)

                dateformat.dateFormat = "hh:mm a"
                let timeStr = dateformat.string(from: time!)

                cell.lbl2.text = "\(dateStr) \(timeStr)"

                cell.btnChatAndPrice.addTarget(self, action: #selector(chatButtonClick(sender:)), for: UIControlEvents.touchUpInside)


                if(eventVisitType == "past")
                {
                    cell.btnChatAndPrice.isHidden = true
                }
//                else
//                {
//                    if (dicEventDetail["price"] as! NSString).doubleValue == 0
//                    {
//                        if( dicEventDetail["status"] as! String == utilityObject.kStatusAccepted)
//                        {
//                            cell.btnChatAndPrice.isHidden = false
//                        }
//                    }
//                }


                //cell.btnChatAndPrice.layer.cornerRadius = 5

            }
            else
                if(arrMenu[indexPath.row] as! String == descriptionType)
                {
                    cell.imgClock.isHidden = true
                    cell.lbl2.isHidden = true
                    cell.btnChatAndPrice.isHidden = true
                    cell.lbl1.text = dicEventDetail.value(forKey: "description") as! String?
                }
                else
                    if(arrMenu[indexPath.row] as! String == addressType)
                    {
                        cell.imgClock.image = UIImage.init(named: "location")
                        cell.lbl1.isHidden = true
                        cell.btnChatAndPrice.isHidden = true
                        cell.lbl2.text = dicEventDetail.value(forKey: "address") as! String?

                        cell.constratentClockImageHeight.constant = 20;
                        
                        cell.constratentAddressLabelTrailing.constant = -(cell.btnChatAndPrice.frame.size.width + 10);
                        
//                        var frame : CGRect = (cell.imgClock?.frame)!
//                        frame.size.height = frame.size.width+1
//                        cell.imgClock.frame = frame
                    }
                    else
                        if(arrMenu[indexPath.row] as! String == priceType)
                        {
                            cell.imgClock.isHidden = true
                            cell.lbl2.isHidden = true
//                            cell.lbl1.text = "Price"

                            cell.btnChatAndPrice.setImage(UIImage.init(named: "NextArrow"), for: UIControlState.normal)

                            if (dicEventDetail["price"] as! NSString).doubleValue == 0
                            {
                                cell.lbl1.text = "Precio por persona: Gratis"


//                                if(eventVisitType == "past")
//                                {
//                                    cell.btnChatAndPrice.isHidden = true
//                                }
//                                else{
//                                    cell.constratentLbl1Trialing.constant = -(cell.btnChatAndPrice.frame.size.width + 10);
//                                }

                                
                                if( dicEventDetail["status"] as! String == utilityObject.kStatusNoRequested)
                                {
//                                    cell.btnWidthConstraint.constant = cell.btnWidthConstraint.constant + 30
                                    
                                    cell.btnChatAndPrice .setTitle("Enviar petición", for: UIControlState.normal)
                                    
//                                    if(DisplayType.iphone5 == Display.typeIsLike || DisplayType.iphone4 == Display.typeIsLike)
//                                    {
////                                        if(cell.btnChatAndPrice.isHidden == false)
////                                        {
////                                            cell.lbl1.font = cell.lbl1.font.withSize(13);
////                                        }
//                                        cell.btnWidthConstraint.constant = cell.btnWidthConstraint.constant + 27
//                                    }
//                                    else
//                                    {
                                        cell.btnWidthConstraint.constant = cell.btnWidthConstraint.constant + 30
//                                    }



                                }
                                else
                                    if( dicEventDetail["status"] as! String == utilityObject.kStatusPending)
                                    {
                                        cell.btnWidthConstraint.constant = cell.btnWidthConstraint.constant+60
                                        cell.btnChatAndPrice.setImage(UIImage.init(named: "RightTick"), for: UIControlState.normal)

                                        cell.btnChatAndPrice .setTitle("Solicitud pendiente", for: UIControlState.normal)
                                        cell.btnChatAndPrice.isEnabled = false
                                    }
                                    else
                                        if( dicEventDetail["status"] as! String == utilityObject.kStatusAccepted)
                                        {
                                            cell.btnWidthConstraint.constant = cell.btnWidthConstraint.constant+20
                                            cell.btnChatAndPrice.setImage(UIImage.init(named: "RightTick"), for: UIControlState.normal)

                                            cell.btnChatAndPrice .setTitle("Confirmado", for: UIControlState.normal)
                                            cell.btnChatAndPrice.isEnabled = false

                                        }
                                        else
                                            if( dicEventDetail["status"] as! String == utilityObject.kStatusDeclined )
                                            {
                                                cell.btnChatAndPrice.setImage(UIImage.init(named: ""), for: UIControlState.normal)

                                                cell.btnChatAndPrice .setTitle("Negado", for: UIControlState.normal)
                                                cell.btnChatAndPrice.isEnabled = false
                                            }






                            }
                            else
                            {
                                // Usted es pagado = You are paid
                                cell.btnWidthConstraint.constant = cell.btnWidthConstraint.constant+20
                                cell.btnChatAndPrice .setTitle("Acceder", for: UIControlState.normal)
                                cell.lbl1.text = "Precio por persona: $\(dicEventDetail["price"] as! NSString)"

                                
                                if( dicEventDetail["status"] as! String == utilityObject.kStatusAccepted)
                                {
                                    cell.btnWidthConstraint.constant = cell.btnWidthConstraint.constant+20
                                    
                                    cell.btnChatAndPrice.setImage(UIImage.init(named: "RightTick"), for: UIControlState.normal)
                                    
                                    cell.btnChatAndPrice .setTitle("Confirmado", for: UIControlState.normal)
                                    cell.btnChatAndPrice.isEnabled = false
                                    
                                    
                                }
                                
                                

                            }


                            if(eventVisitType == "past")
                            {
                                cell.btnChatAndPrice.isHidden = true
                            }
                            else
                                //                                if(cell.btnChatAndPrice.isHidden == false)
                            {
                                cell.constratentLbl1Trialing.constant = (cell.btnWidthConstraint.constant + 10);
                            }
                            

                            //Siguiente

                            if(dicEventDetail.value(forKey: "createdby") as! String != ((UtilityClass().getUserDefault(key: "userinfo") as! NSDictionary).value(forKey: "id")) as! String)
                            {
                                cell.btnChatAndPrice.addTarget(self, action: #selector(PaymentButtonClick(sender:)), for: UIControlEvents.touchUpInside)
                            }
                            else
                            {
                                cell.btnChatAndPrice.isHidden = true
                            }
                        }
                        else
                            if(arrMenu[indexPath.row] as! String == durationType)
                            {
                                cell.imgClock.isHidden = true
                                cell.lbl2.isHidden = true
                                cell.btnChatAndPrice.isHidden = true

                                if(Int(dicEventDetail["duration"] as! String) == 1)
                                {
                                    cell.lbl1.text = "Duracion: \(dicEventDetail["duration"] as! String) hora"
                                }
                                else{
                                    cell.lbl1.text = "Duracion: \(dicEventDetail["duration"] as! String) horas"
                                }

//                                cell.lbl1.text = "Duracion: \(dicEventDetail.value(forKey: "duration") as! String) h"
                            }
                            else
                                if(arrMenu[indexPath.row] as! String == capacity)
                                {
                                    cell.imgClock.isHidden = true
                                    cell.lbl2.isHidden = true
                                    cell.btnChatAndPrice.isHidden = true
                                    cell.lbl1.text = "Capacidad del lugar: \(dicEventDetail.value(forKey: "capacity") as! String) people"
                                }

        return cell
    }


//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 160
//        
//    }
//    
//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        if(indexPath.row<5)
//        {
//            
//            return 87.0
//        }
//        else{
//            return 120
//        }
//    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(arrMenu[indexPath.row] as! String == attendeesType)
        {
            return 120
        }
        else
        
        if(arrMenu[indexPath.row] as! String != eventName)
        {
            return 87
        }
//        else
//            if(arrMenu[indexPath.row] as! String == dateType)
//            {
//                return 87
//            }
//            else
//                if(arrMenu[indexPath.row] as! String == descriptionType)
//                {
//                    return 87
//                }
//                else
//                    if(arrMenu[indexPath.row] as! String == addressType)
//                    {
//                        return 87
//                    }
//                    else
//                        if(arrMenu[indexPath.row] as! String == priceType)
//                        {
//                            return 87
//                        }
//                        else
//                            if(arrMenu[indexPath.row] as! String == durationType)
//                            {
//                                return 87
//                            }
//                            else
//                                if(arrMenu[indexPath.row] as! String == capacity)
//                                {
//                                    return 87
//                                }
        
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {

    }


    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        //        switch kind {
        //
        //        case UICollectionElementKindSectionHeader:

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)

        //            let headerView = collectionView.dequeueReusableCell(withReuseIdentifier: "header", for: indexPath) as! EventInfoCollectionViewCell

        return headerView

        //        default:
        //
        //            assert(false, "Unexpected element kind")
        //        }
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrayAttendees.count
    }



    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let reuseIdentifier = "collectionCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventInfoCollectionViewCell

        let dic: NSDictionary = arrayAttendees[indexPath.row] as! NSDictionary

        cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height/2
        cell.imgProfile.layer.borderWidth = 1

        cell.imgProfile.layer.masksToBounds = true

        cell.imgProfile.sd_setImage(with: URL.init(string: dic.value(forKey: "profilepic") as! String), placeholderImage: UIImage.init(named: "profile_pic"))

        //        cell.imgProfile.rounded
        //        cell.imgProfile.circle

        return cell
    }

    //MARK:

    func PaymentButtonClick(sender: UIButton)
    {

        let userInfo : NSDictionary = UtilityClass().getUserDefault(key: "userinfo") as!  NSDictionary
//        let age = userInfo.value(forKey: "age")
        var isMale = true
        if(userInfo.value(forKey: "gender") as! String).lowercased() == "f"
        {
            isMale = false
        }

        let age = comman().calcAge(birthday: userInfo.value(forKey: "dob") as! String)

        if(Int(dicEventDetail.value(forKey: "maleage") as! String) != 0 && isMale == true && Int(dicEventDetail.value(forKey: "maleage") as! String)! > age )
        {
            let alert = UIAlertController(title: "alerta", message: "Usted no es elegible debido a la restricción de edad", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))

            DispatchQueue.main.async{
                self.present(alert, animated: true, completion: nil)
            }

            return
        }
        else if( Int(dicEventDetail.value(forKey: "femaleage") as! String)! != 0 && Int(dicEventDetail.value(forKey: "femaleage") as! String)! > age)
        {
            let alert = UIAlertController(title: "alerta", message: "Usted no es elegible debido a la restricción de edad", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))

            DispatchQueue.main.async{
                self.present(alert, animated: true, completion: nil)
            }

            return
        }



        let capacity = Int(NSString(format: "%@", dicEventDetail.value(forKey: "capacity") as! CVarArg) as String)

        let femaleCount = Int(NSString(format: "%@", dicEventDetail.value(forKey: "femaleCount") as! CVarArg) as String)
        let maleCount = Int(NSString(format: "%@", dicEventDetail.value(forKey: "maleCount") as! CVarArg) as String)

        if capacity != 0 && (capacity! <= (femaleCount! + maleCount!))
        {
            let alert = UIAlertController(title: "alerta", message: "La capacidad de unirse a eventos está llena", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))

            DispatchQueue.main.async{
                self.present(alert, animated: true, completion: nil)
            }

            return

        }

        if (dicEventDetail["price"] as! NSString).doubleValue == 0
        {
            SVProgressHUD.show(withStatus: "por favor espera")

            APIModal().joinevent(eventid: dicEventDetail["id"] as! String, target: self, action: #selector(joinEventHandle(response:)))
        }
        else
        {
//            let addCardViewController = STPAddCardViewController()
//            addCardViewController.delegate = self
//            // STPAddCardViewController must be shown inside a UINavigationController.
//            let navigationController = UINavigationController(rootViewController: addCardViewController)
//            self.present(navigationController, animated: true, completion: nil)


            paymentByCard()
            
//            let paymentVC: PaymentVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
//            
//            paymentVC.eventDic = dicEventDetail
//            
//            self.navigationController?.pushViewController(paymentVC, animated: true)
        }

    }


    func joinEventHandle(response: AnyObject)
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
            let alert = UIAlertController(title: "alerta", message: "Solicitud enviada correctamente", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))

            DispatchQueue.main.async{
                self.present(alert, animated: true, completion: nil)
                
                self.dicEventDetail.setValue(utilityObject.kStatusPending, forKey: "status")
                
                let indexPath = IndexPath(item: 4, section: 0)
                
                self.table.reloadRows(at: [indexPath], with: .top)
                
            }

        }
    }



    func chatButtonClick(sender: UIButton)
    {
         


//        QBRequest.updateDialog(updateDialog, successBlock: {(responce: QBResponse?, dialog: QBChatDialog?) in
//
//        }, errorBlock: {(response: QBResponse!) in
//            
//        })
//
//
        getDialogs()
    }



    func getDialogs()
    {

//        SVProgressHUD.show(withStatus: "por favor espera")
//        QBRequest.dialogs(successBlock: { (respose, dialogObjects, dialogsUsersIDS) in

            let dialogObjects =  ModelManager().getDialogs()


            let dialogId : String! = self.dicEventDetail.value(forKey: "groupId") as! String

            for chatDialog in dialogObjects
            {
                if chatDialog.id == dialogId
                {

//                    let id = NSNumber (value: Int(ServiceClass.sharedInstance.currentUser.id))
//
//                    chatDialog.occupantIDs = [id]

                    let chatVC : GroupChat = self.storyboard?.instantiateViewController(withIdentifier: "GroupChat") as! GroupChat
                    
                    chatVC.dialog = chatDialog
                    
                    self.navigationController?.pushViewController(chatVC, animated: true)
                    

                    SVProgressHUD.dismiss()


                    break
                }
            }

//        }) { (response) in
//            SVProgressHUD.dismiss()
//            print("\(response.error)")
//        }
    }



    //MARK:
    // MARk: Get attendees list
    func getAttendees()
    {
        APIModal().eventattendies(eventid: dicEventDetail["id"] as! String, target: self, action: #selector(getAttendeesHandle(response:)))
    }


    func getAttendeesHandle(response: AnyObject)
    {
        let jsonResult : Dictionary = (response as? Dictionary<String, AnyObject>)!

        if (jsonResult["error"]as! Bool) == true
        {
//            let alert = UIAlertController(title: "alerta", message: jsonResult["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//
//            DispatchQueue.main.async{
//                self.present(alert, animated: true, completion: nil)
//            }
        }
        else
        {

            arrayAttendees = jsonResult["data"] as! NSArray

            DispatchQueue.main.async{

                let indexPath = IndexPath(item: self.arrMenu.index(of: self.attendeesType), section: 0)

                self.table.reloadRows(at: [indexPath], with: .top)
            }
        }
    }


    // MARK: 
    // MARK: payment methods
    
    func paymentByCard()
    {
        
                let addCardViewController = STPAddCardViewController()
                addCardViewController.delegate = self
                // STPAddCardViewController must be shown inside a UINavigationController.
                let navigationController = UINavigationController(rootViewController: addCardViewController)
                self.present(navigationController, animated: true, completion: nil)
        
        
       /* let cardParams = STPCardParams()
        
        cardParams.number = "4242424242424242"
        cardParams.expMonth = 10
        cardParams.expYear = 2018
        cardParams.cvc = "123"
        
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
            
            if(error==nil)
            {
                
                APIModal().makepayment(eventid: self.eventDic["id"] as! String, token: "hgwerhehrr", amount: "200", target: self, action: #selector(self.paymentHandle(response:)))
            }
            else
            {
                SVProgressHUD.showError(withStatus: error.debugDescription)
                
            }
            
        }
        */
        
    }
    
    func paymentHandle(response: AnyObject)
    {
        
        SVProgressHUD.dismiss()
        
        
        self.dismiss(animated: true, completion: nil)
        
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
            let alert = UIAlertController(title: "alerta", message: "Pago hecho con éxito", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            DispatchQueue.main.async{
                self.present(alert, animated: true, completion: nil)
                
                self.dicEventDetail.setValue(utilityObject.kStatusAccepted, forKey: "status")
                
                let indexPath = IndexPath(item: 4, section: 0)
                
                self.table.reloadRows(at: [indexPath], with: .top)
                
                self.getAttendees()
            }
        }
    }
    
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        APIModal().makepayment(eventid: dicEventDetail["id"] as! String, token: token.tokenId, amount: dicEventDetail["price"] as! String, target: self, action: #selector(self.paymentHandle(response:)))
        
    }
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.dismiss(animated: true, completion: nil)
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


