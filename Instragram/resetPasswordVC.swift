//
//  resetPasswordVC.swift
//  Instragram
//
//  Created by olos on 10.02.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit
import Parse

class resetPasswordVC: UIViewController {
    
    
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var resetBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    @IBAction func resetBtn_click(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if emailTxt.text!.isEmpty {
            let alert = UIAlertController(title: "PLEASE", message: "fill email adress", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        PFUser.requestPasswordResetForEmail(inBackground: emailTxt.text!) { (success, error) in
            
            if success {
            let alert = UIAlertController(title: "Email fo reseting password", message: "has been sent to texted email", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription)
                
            }
        }
        
    }
    
    @IBAction func cancelBtn_click(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func hideKeyboard(_ recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg2.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)

        // hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(resetPasswordVC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
