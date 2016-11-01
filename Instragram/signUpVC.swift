//
//  signUpVC.swift
//  Instragram
//
//  Created by olos on 10.02.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit
import Parse

class signUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    
    
    @IBOutlet var avaimg: UIImageView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var repeatPassword: UITextField!
    @IBOutlet var fullnameTxt: UITextField!
    @IBOutlet var bioTxt: UITextField!
    @IBOutlet var webTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    
    
    // scroll view
    @IBOutlet var scrollView: UIScrollView!
    
    // reset default size
    var scrollViewHeight: CGFloat = 0
    
    // keyboard frame
    var keyboard = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg2.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        
        // scrollview frame size
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        // check notifications if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(signUpVC.showKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signUpVC.hideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signUpVC.hideKeyboardTab(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // round ava
        avaimg.layer.cornerRadius = avaimg.frame.size.width / 2
        avaimg.clipsToBounds = true
        
        
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(signUpVC.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaimg.isUserInteractionEnabled = true
        avaimg.addGestureRecognizer(avaTap)
        

        
    }
    
    // call picker to select image
    func loadImg(_ recognizer: UITapGestureRecognizer) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    // connect selected image to our ImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaimg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func hideKeyboardTab(_ recognizer: UITapGestureRecognizer) {
        
        // hide keyboard if tapped
        self.view.endEditing(true)
    }
    
    
    

    func showKeyboard(_ notification: Notification) {
        
        // define keyboard size
        keyboard = (((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move up UI
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }) 
        
    }
    
    func hideKeyboard(_ notification: Notification) {
        
       UIView.animate(withDuration: 0.4, animations: { () -> Void in
        
        // move down UI
        self.scrollView.frame.size.height = self.view.frame.height
        
        }) 
        
    }
    
    
    
    @IBAction func signUpBtn_click(_ sender: AnyObject) {
        print("sign up pressed")
        
        self.view.endEditing(true)
        
        if (usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPassword.text!.isEmpty || fullnameTxt.text!.isEmpty || bioTxt.text!.isEmpty || webTxt.text!.isEmpty || emailTxt.text!.isEmpty) {
            
            let alert = UIAlertController(title: "PLEASE", message: "fill all fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if passwordTxt.text != repeatPassword.text {
            
            let alert = UIAlertController(title: "PASSWORD", message: "do not match", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
 
        }
        
        // send data to serwer
        let user = PFUser()
        
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["bio"] = bioTxt.text?.lowercased()
        user["web"] = webTxt.text?.lowercased()
        
        user["tel"] = ""
        user["gender"] = ""
        
        // convert ava image for sending to server
        let avaData = UIImageJPEGRepresentation(avaimg.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        // save data in server
        user.signUpInBackground { (success, error) -> Void in
            
            if success {
                print("registered")
                
                // Save data in device and remember logged user
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login func from AppDelegate.swift class
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            }else{
                
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)

            }
            
            
        }
  
    }
    
    @IBAction func cancelBtn_click(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
