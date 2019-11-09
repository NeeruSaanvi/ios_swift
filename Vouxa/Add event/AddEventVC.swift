//
//  AddEventVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import GooglePlaces
import SVProgressHUD

class AddEventVC: BaseViewController, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var scrollView :TPKeyboardAvoidingScrollView!
    @IBOutlet weak var txtEventName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtDuration: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtCapacity: UITextField!
    @IBOutlet weak var txtMaleAge: UITextField!
    @IBOutlet weak var txtFeMaleAge: UITextField!
    @IBOutlet weak var switchAge: UISwitch!
    @IBOutlet weak var switchPayment: UISwitch!
    @IBOutlet weak var txtDiscription: UITextView!
    @IBOutlet weak var viewAge: UIView!
    @IBOutlet weak var btnAddEventTopConstant: NSLayoutConstraint!

    @IBOutlet weak var viewAgaTopConstant: NSLayoutConstraint!

    @IBOutlet weak var txtPriceTopConstant: NSLayoutConstraint!



    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var pickerDateAndTime: UIDatePicker!
    @IBOutlet weak var btnCreateEvent: UIButton!
    var cordinates: CLLocationCoordinate2D!
    
    var dialogId: String!
    
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var selectedTextField: UITextField!
    var selectedTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        addNotificationButton()
        
        setDateDefaultDate()
        
        
        pickerDateAndTime.locale = Locale(identifier: "es-cl")
        
        // btnCreateEvent.layer.cornerRadius = 5
        
        
        txtDiscription.layer.cornerRadius = 5
        txtDiscription.layer.borderWidth = 1
        txtDiscription.textColor = UIColor.lightGray
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
    }


    override func viewDidLayoutSubviews() {
                scrollView?.contentSizeToFit()

//        scrollView.contentSize = CGSize.init(width: 0, height: ( btnCreateEvent .frame.origin.y - viewAge.frame.size.height + 18 ) )

    }


    func setDateDefaultDate()
    {
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.minute = 60
        let minDate: Date = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as Date
        
        pickerDateAndTime.minimumDate = minDate as Date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm a"
        
        lblDateTime.text = formatter.string(from: minDate)
    }
    
    
    // MARK:
    // MARK: Create Event Button
    @IBAction func createEventButtonClick(sender: UIButton)
    {
        if !(comman().validateTextFiled(textfiled: txtEventName!))
        {
            let alert = UIAlertController(title: "alerta", message: "Introduzca el nombre del evento", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        else
            if !(comman().validateTextFiled(textfiled: txtAddress!))
            {
                let alert = UIAlertController(title: "alerta", message: "Introduce la dirección del evento", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            else
                if (!(comman().validateTextFiled(textfiled: txtPrice!)) && switchPayment.isOn == true)
                {
                    let alert = UIAlertController(title: "alerta", message: "Introduzca el precio del evento", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                    //        else
                    //                    if !(comman().validateTextFiled(textfiled: txtCapacity!))
                    //                    {
                    //                        let alert = UIAlertController(title: "alerta", message: "Ingrese la capacidad del evento", preferredStyle: UIAlertControllerStyle.alert)
                    //                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    //
                    //                        self.present(alert, animated: true, completion: nil)
                    //        }
                else
                    if (switchAge?.isOn)! && !comman().validateTextFiled(textfiled: txtMaleAge!)
                    {
                        let alert = UIAlertController(title: "alerta", message: "Por favor ingrese la edad masculina", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    else
                        if (switchAge?.isOn)! && !comman().validateTextFiled(textfiled: txtFeMaleAge!)
                        {
                            let alert = UIAlertController(title: "alerta", message: "Ingrese la edad de la mujer", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        else
                        {
                            
                            
                            SVProgressHUD.show(withStatus: "por favor espera...")
                            
                            //                                    let createdBy = (UtilityClass().getUserDefault(key: "userinfo") as! NSDictionary).value(forKey: "id") as! String
                            
                            ServiceClass.sharedInstance.createGroup(groupName: txtEventName.text!, completion: { (response, createdDialog) in
                                
                                
                                
                                
                                guard let unwrappedResponse = response else {
                                    print("Error empty response")
                                    return
                                }
                                
                                if let error = unwrappedResponse.error {
                                    print(error.error as Any)
                                    SVProgressHUD.showError(withStatus: error.error?.localizedDescription)
                                }
                                else {
                                    
                                    SVProgressHUD.show(withStatus: "por favor espera...")
                                    self.dialogId = (createdDialog?.id)!
                                    
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "dd/MM/yyyy hh:mm a"
                                    let date: Date = formatter.date(from: self.lblDateTime.text!)!
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    let strDate = formatter.string(from: date)
                                    
                                    formatter.dateFormat = "HH:mm:ss"
                                    let strTime = formatter.string(from: date)

                                    var capacity : String = (self.txtCapacity?.text)!
                                    if(capacity == "")
                                    {
                                        capacity = "0"
                                    }


                                    var discription : String = (self.txtDiscription?.text)!
                                    if(discription == "" || self.txtDiscription.text.lowercased() == "descripción")
                                    {
                                        discription = " "
                                    }

                                    var price: String = self.txtPrice.text!
                                    if(price == "")
                                    {
                                        price = "0"
                                    }

                                    
                                    APIModal().addEvent(eventName: (self.txtEventName?.text)!, description: discription, starttime: strTime, address: (self.txtAddress?.text)!, duration: (self.txtDuration?.text!)!, price: price, capacity: capacity, maleage: (self.txtMaleAge?.text!)!, femaleage: (self.txtFeMaleAge?.text!)!, heldon: strDate, latitude: String(format:"%f", self.cordinates.latitude), longitude: String(format:"%f", self.cordinates.longitude), groupId:(createdDialog?.id)!, target: self, action:#selector(AddEventVC.addEventHandle(response:)) )
                                    
                                }
                            })
                            
                            
                            //                                    ServiceClass.sharedInstance.createGroup(groupName: txtEventName.text!, completion: completion)
                            
                            
                            
                            
                            
        }
        
    }
    
    // MARK: Add Event Response handle
    
    func addEventHandle(response: AnyObject)
    {
        let jsonResult : Dictionary = (response as? Dictionary<String, AnyObject>)!
        
        SVProgressHUD.dismiss()
        if (jsonResult["error"]as! Bool) == true
        {
            
            ServiceClass.sharedInstance.deleteDialog(dialogId: dialogId)
            
            let alert = UIAlertController(title: "alerta", message: jsonResult["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            DispatchQueue.main.async{
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            DispatchQueue.main.async{
                let vc : AddEventConfirmationVC = self.storyboard?.instantiateViewController(withIdentifier: "AddEventConfirmationVC") as! AddEventConfirmationVC
                vc.eventName = self.txtEventName.text
                vc.eventAddress = self.txtAddress.text
                vc.eventDateTime = self.lblDateTime.text
                
                self.navigationController?.pushViewController(vc, animated: true)
                
                
                self.txtEventName.text = ""
                self.txtAddress.text = ""
                self.txtDuration.text = ""
                self.txtPrice.text = ""
                self.txtCapacity.text = ""
                self.txtMaleAge.text = ""
                self.txtFeMaleAge.text = ""
                //                switchAge.text = ""
                self.txtDiscription.text = "Descripción"
                self.txtDiscription.textColor = UIColor.lightGray
                self.setDateDefaultDate()

                ServiceClass.sharedInstance.getDialogs()
            }
        }
    }
    @IBAction func pickerScrollingOnvalueChangeMethod(picker: UIDatePicker)
    {
        
        let date: Date = picker.date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm a"
        
        lblDateTime.text =  formatter.string(from: date)
        
        
    }
    
    @IBAction func switchChangeAction(sender: UISwitch)
    {
        if sender.isOn
        {
            viewAge?.isHidden = false

            viewAgaTopConstant?.constant =  18.0

            btnAddEventTopConstant?.constant = (viewAge?.frame.size.height)! + 30.0
            sender.thumbTintColor = UIColor.white

            scrollView.contentSize = CGSize.init(width: 0, height: ( btnCreateEvent .frame.origin.y + viewAge.frame.size.height + 18 ) )
        }
        else
        {
            viewAgaTopConstant?.constant =  -50
            viewAge?.isHidden = true
            btnAddEventTopConstant?.constant = 30.0
            sender.thumbTintColor = utilityObject.mainColor

            scrollView.contentSize = CGSize.init(width: 0, height: ( btnCreateEvent .frame.origin.y - viewAge.frame.size.height + 18 ) )
        }



    }
    
    
    @IBAction func paymentTypeSelectionClick(sender: UISwitch)
    {
        if sender.isOn
        {
            sender.thumbTintColor = UIColor.white
            txtPrice.text = ""
            txtPrice.isHidden = false
            txtPriceTopConstant.constant = 4
        }
        else
        {
            sender.thumbTintColor = utilityObject.mainColor
            txtPrice.isHidden = true
            txtPrice.text = "0"
            txtPriceTopConstant.constant = -20
        }

//
        scrollView.contentSizeToFit()
//
//        if switchAge.isOn
//        {
//            scrollView.contentSize = CGSize.init(width: 0, height: ( btnCreateEvent .frame.origin.y + viewAge.frame.size.height + 18 ) )
//        }
//        else
//        {
//            scrollView.contentSize = CGSize.init(width: 0, height: ( btnCreateEvent .frame.origin.y - viewAge.frame.size.height + 18 ) )
//        }

        
    }
    //MARK: add Autocomplete
    
    // Present the Autocomplete view controller when the button is pressed.
    
    func autocompleteClicked() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    //MARK: Autocomplete Delegates
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        txtAddress?.text = place.formattedAddress
        cordinates = place.coordinate
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //MARK:
    //MARK: textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        selectedTextField = textField
        addToolBar(textField: textField)
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(textField == txtAddress)
        {
            autocompleteClicked()
        }
    }
    
    
    // MARK: textview delegates
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        if (textView.text.lowercased() == "descripción")
        {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        selectedTextView = textView
        addToolBarFortextView(textView: textView)
        
        
        return true
    }
    
    
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text.lowercased() == "")
        {
            textView.text = "Descripción"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        
        
        let nsString = textView.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: text)
        
        
        
        
    
        if(textView == txtDiscription && (newString?.characters.count)! > 150 )
        {
            return false
        }
        
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addToolBar(textField: UITextField)
    {
        let keyboardToolBar: UIToolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        
        keyboardToolBar.barStyle = UIBarStyle.default
        
        let previous = UIBarButtonItem.init(title: "Anterior", style: UIBarButtonItemStyle.plain, target: self, action: #selector(previousKeyboardClick(barbutton:)))
        
        let next = UIBarButtonItem.init(title: "Siguiente", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextKeyboardClick(barbutton:)))
        
        let space = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let done =  UIBarButtonItem.init(title: "Hecho", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneKeyboardClick(barbutton:)))
        
        keyboardToolBar.setItems([previous,next, space,done], animated: true)
        
        textField.inputAccessoryView = keyboardToolBar
        
        previous.isEnabled = true
        next.isEnabled = true
        
        if(textField == txtEventName)
        {
            previous.isEnabled = false
        }
        else
            if(textField == txtFeMaleAge)
            {
                next.isEnabled = false
        }
        
    }
    
    func addToolBarFortextView(textView: UITextView)
    {
        let keyboardToolBar: UIToolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        
        
        keyboardToolBar.barStyle = UIBarStyle.default
        
        keyboardToolBar.setItems([UIBarButtonItem.init(title: "Anterior", style: UIBarButtonItemStyle.plain, target: self, action: #selector(previousTextViewKeyboardClick(barbutton:))),UIBarButtonItem.init(title: "Siguiente", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextTextViewKeyboardClick(barbutton:))), UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),UIBarButtonItem.init(title: "Hecho", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneKeyboardClick(barbutton:)))], animated: true)
        
        
        textView.inputAccessoryView = keyboardToolBar
        
    }
    
    
    
    func doneKeyboardClick(barbutton: UIBarButtonItem)
    {
        scrollView.endEditing(true)
    }
    
    func nextKeyboardClick(barbutton: UIBarButtonItem)
    {
        
        let textField: UITextField = selectedTextField;
        
        textField.resignFirstResponder()
        
        if(textField == txtEventName)
        {
            txtAddress.becomeFirstResponder()
        }
        else
            if(textField == txtAddress)
            {
                txtDuration.becomeFirstResponder()
            }
            else
                if(textField == txtDuration)
                {
                    if(switchPayment.isOn)
                    {
                        txtPrice.becomeFirstResponder()
                    }
                    else
                    {
                        txtDiscription.becomeFirstResponder()
                    }
                    
                    //                    txtPrice.becomeFirstResponder()
                }
                else
                    if(textField == txtPrice)
                    {
                        txtDiscription.becomeFirstResponder()
                    }
                    else
                        if(textField == txtCapacity && switchAge.isOn)
                        {
                            txtMaleAge.becomeFirstResponder()
                            
                        }
                        else
                            if(textField == txtMaleAge && switchAge.isOn)
                            {
                                txtFeMaleAge.becomeFirstResponder()
        }
        
        
    }
    
    
    func previousKeyboardClick(barbutton: UIBarButtonItem)
    {
        let textField: UITextField = selectedTextField;
        
        textField.resignFirstResponder()
        
        if(textField == txtAddress )
        {
            txtEventName.becomeFirstResponder()
        }
        else
            if(textField == txtDuration)
            {
//                txtAddress.becomeFirstResponder()
            }
            else
                if(textField == txtPrice)
                {
                    txtDuration.becomeFirstResponder()
                }
                else
                    if(textField == txtCapacity)
                    {
                        
                        txtDuration.becomeFirstResponder()
                        
                    }
                    else
                        if(textField == txtMaleAge && switchAge.isOn)
                        {
                            txtCapacity.becomeFirstResponder()
                            
                        }
                        else
                            if(textField == txtFeMaleAge && switchAge.isOn)
                            {
                                txtMaleAge.becomeFirstResponder()
        }
    }
    
    
    
    func nextTextViewKeyboardClick(barbutton: UIBarButtonItem)
    {
        let textView: UITextView = selectedTextView;
        
        textView.resignFirstResponder()
        
        if(textView == txtDiscription )
        {
            txtCapacity.becomeFirstResponder()
        }
        
    }
    
    
    func previousTextViewKeyboardClick(barbutton: UIBarButtonItem)
    {
        let textView: UITextView = selectedTextView;
        
        textView.resignFirstResponder()
        
        if(textView == txtDiscription )
        {
            
            if(switchPayment.isOn)
            {
                txtPrice.becomeFirstResponder()
            }
            else
            {
                txtDuration.becomeFirstResponder()
            }
        }
        
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



