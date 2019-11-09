//
//  FilterVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/2/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class FilterVC: BaseViewController, MBSliderDelegate {

    @IBOutlet weak var sliderAge: MBSliderView!
    @IBOutlet weak var sliderDistance: MBSliderView!
    @IBOutlet weak var sliderPrice: MBSliderView!
    @IBOutlet weak var btnDate: UIButton?
    @IBOutlet weak var lblMaxPrice: UILabel!
    @IBOutlet weak var lblMaxDistance: UILabel!
    @IBOutlet weak var lblMaxAge: UILabel!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet var scrollView: TPKeyboardAvoidingScrollView!
    
    var lblAgeValue: UILabel!
    var lblDistanceValue: UILabel!
    var lblPriceValue: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        addSlideMenuButton()
        addNotificationButton()
        
//        let date: Date = pickerView.date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        btnDate?.setTitle(formatter.string(from: Date()), for: UIControlState.normal)
        
        sliderAge.delegate = self;
        sliderPrice.delegate = self;
        sliderDistance.delegate = self;
//        MBSliderView().delegate = self
//        sliderAge.delegate = self
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {

        setValues()

       // lblMaxAge.text = mapStruct.lblMaxAgeStr
       // lblMaxDistance.text = mapStruct.lblMaxDistanceStr
       // lblMaxPrice.text = "$\(mapStruct.lblMaxPriceStr)"
        
    }

    
    override func viewDidLayoutSubviews() {
        scrollView.contentSizeToFit()
    }

    func setValues()
    {
        sliderAge.currentValue = Float.init(mapStruct.sliderAgeStr)

//        lblAgeValue.bounds  = sliderAge.thu
        sliderDistance.currentValue = Float.init(mapStruct.sliderDistanceStr)

        sliderPrice.currentValue = Float.init(mapStruct.sliderPriceStr)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let date = formatter.date(from: mapStruct.btnDateStr)
        formatter.dateFormat = "dd/MM/yyyy"

        if(date != nil)
        {
            btnDate?.setTitle(formatter.string(from: date!), for: UIControlState.normal)
        }
        else{
            btnDate?.setTitle("00/00/0000", for: UIControlState.normal)
        }
        

    }


    func sliderView(_ sliderView: MBSliderView, valueDidChange value: Float) {
        if sliderView == sliderPrice {
            print("sliderFromStoryBoard: \(value)")
            mapStruct.sliderPriceStr = value
        } else if sliderView == sliderAge {
            print("sliderFromCode: \(value)")
            mapStruct.sliderAgeStr = value
        }
        else if(sliderView == sliderDistance)
        {
            mapStruct.sliderDistanceStr = value
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
//        self.navigationController!.popToRootViewController(animated: false)

        }

    //MARK:
    
    @IBAction func sliderAge(sender: UISlider)
    {
        
    }

    @IBAction func sliderPrice(sender: UISlider)
    {
        
    }

    @IBAction func sliderDistance(sender: UISlider)
    {
        
    }

    @IBAction func btnDate(sender: UIButton)
    {
//        mapStruct.sliderAgeStr = sender.value
        viewPicker.frame=CGRect(x: 0 , y: UIScreen.main.bounds.size.height, width: viewPicker.bounds.size.width, height: viewPicker.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            
            self.viewPicker.frame=CGRect(x: 0, y: UIScreen.main.bounds.size.height-self.viewPicker.bounds.size.height-(self.tabBarController?.tabBar.frame.size.height)!, width: self.viewPicker.bounds.size.width, height: self.viewPicker.bounds.size.height);
            
//            sender.isEnabled = true
        }, completion:nil)
    }


    @IBAction func doneButtonClick(sender: UIButton)
    {
        hidePickerView()
        let date: Date = pickerView.date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        btnDate?.setTitle(formatter.string(from: date), for: UIControlState.normal)

        formatter.dateFormat = "yyyy-MM-dd"
        
        mapStruct.btnDateStr = formatter.string(from: date)
    }


    
    @IBAction func cancelButtonClick(sender: UIButton)
    {
        hidePickerView()
    }
    
    func hidePickerView()
    {
//        viewPicker.frame=CGRect(x: 0 , y: UIScreen.main.bounds.size.height, width: viewPicker.bounds.size.width, height: viewPicker.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.viewPicker.frame=CGRect(x: 0 , y: UIScreen.main.bounds.size.height, width: self.viewPicker.bounds.size.width, height: self.viewPicker.bounds.size.height);
            
//            self.viewPicker.frame=CGRect(x: 0, y: UIScreen.main.bounds.size.height-self.viewPicker.bounds.size.height, width: self.viewPicker.bounds.size.width, height: self.viewPicker.bounds.size.height);
            
            //            sender.isEnabled = true
        }, completion:nil)
    }


    @IBAction func resetFilterButtonClick(sender: UIButton)
    {
        mapStruct.btnDateStr = "0000-00-00"
        mapStruct.sliderAgeStr = 0
        mapStruct.sliderDistanceStr = 0
        mapStruct.sliderPriceStr = 0

        setValues()

//        self.navigationController!.popViewController(animated: true)
    }


    @IBAction func applyFilterButtonClick(sender: UIButton)
    {
//        let arrayVC = self.navigationController!.viewControllers
//
//        var flag = 0
//        for  vc in arrayVC
//        {
//            if(vc .isEqual(EventListVC.self))
//            {
//                flag = 1
//            }
//        }

//
//
//            let index : Int = (tabBarController.viewControllers?.indexOf(viewController))!
//            if index == 0
//            {
//                let navigationController = viewController as? UINavigationController
//                navigationController?.popToRootViewControllerAnimated(true)
//            }





//        if(flag == 1)
//        {
//            self.navigationController!.popViewController(animated: true)
//        }
//        else
//        {



            self.tabBarController?.selectedIndex = 1

        self.navigationController!.popViewController(animated: true)
        
        
//        let navigationcontroller : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "navigationEventList") as! UINavigationController
//
//        navigationcontroller.popToRootViewController(animated: true)

//            let index = self.tabBarController?.viewControllers?.index(of: EventListVC)
//            if(index == 1)
//            {
//                self.view
//            }
//            self.tabBarController?.viewControllers
//        }
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
