//
//  PaymentVC.swift
//  Vouxa
//
//  Created by Piyush Agarwal on 12/6/16.
//  Copyright © 2016 Pinesucceed. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import Stripe.STPCardParams

class PaymentVC: BaseViewController, STPAddCardViewControllerDelegate {

    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView?
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var cardCVV: UITextField!
    @IBOutlet weak var  date: UITextField!
    @IBOutlet weak var month: UITextField!

    var eventDic : NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        addNotificationButton()
        self.title = "Informacion"
//         self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "notification bell"), style: .plain, target: self, action: #selector(notificationButtonTap))

        
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        closeNotificationScreen()
    }

    @IBAction func paymentButtonClick(sender: UIButton)
    {

//        let addCardViewController = STPAddCardViewController()
//        addCardViewController.delegate = self
//        // STPAddCardViewController must be shown inside a UINavigationController.
//        let navigationController = UINavigationController(rootViewController: addCardViewController)
//        self.present(navigationController, animated: true, completion: nil)
        
        
        let cardParams = STPCardParams()

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


    }

    func paymentHandle(response: AnyObject)
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
            
        }
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        
        APIModal().makepayment(eventid: self.eventDic["id"] as! String, token: token.tokenId, amount: self.eventDic["price"] as! String, target: self, action: #selector(self.paymentHandle(response:)))
        
    }
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        scrollView?.contentSizeToFit()
        
    }
    
    func notificationButtonTap(barButton : UIBarButtonItem) {
        
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
