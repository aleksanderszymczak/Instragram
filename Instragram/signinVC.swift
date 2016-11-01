//
//  signinVC.swift
//  Instragram
//
//  Created by olos on 10.02.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit
import Parse

class signinVC: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    //texfields
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    //buttons
    @IBOutlet var signInBtn: UIButton!
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var forgotBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.font = UIFont(name: "Pacifico", size: 30)
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg2.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
    }

    //clicked sign in button
    @IBAction func signInBtn_click(_ sender: AnyObject) {
        print("sign in clicked")
        
        // hide keyboard
        self.view.endEditing(true)
        
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            
            let alert = UIAlertController(title: "PLEASE", message: "fill all fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        // login function
        PFUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!) { (user, error) -> Void in
            
            if error == nil {
                
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
               
            } else {
                
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)

            }
            
            
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
