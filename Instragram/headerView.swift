//
//  headerView.swift
//  Instragram
//
//  Created by olos on 06.03.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit
import Parse

class headerView: UICollectionReusableView {
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var webTxt: UITextView!
    @IBOutlet weak var bioLbl: UILabel!
    
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
    
    @IBOutlet weak var postsTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func followBtn_clicked(_ sender: UIButton) {
        
        let title = button.title(for: UIControlState())
        
        //to follow
        if title == "FOLLOW" {
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = guestname.last
            object.saveInBackground(block: { (success, error) in
                
                if success {
                    
                    self.button.setTitle("FOLLOWING", for: UIControlState())
                    self.button.backgroundColor = UIColor.green
                    
                } else {
                    
                    print(error?.localizedDescription)
                }
            })
            // unfollow
        } else {
            
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: (PFUser.current()?.username)!)
            query.whereKey("following", equalTo: guestname.last)
            query.findObjectsInBackground(block: { (objects, error) in
                
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if success {
                                self.button.setTitle("FOLLOW", for: UIControlState())
                                self.button.backgroundColor = UIColor.lightGray
                                
                            } else {
                                print(error?.localizedDescription)
                                
                            }
                        })
                    }
                    
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //alignment
        
        let width = UIScreen.main.bounds.width
        
        avaImg.frame = CGRect(x: width/16, y: width/16, width: width/4, height: width/4)
        
        posts.frame = CGRect(x: width/2.5, y: avaImg.frame.origin.y, width: 50, height: 30)
        followers.frame = CGRect(x: width/1.7, y: avaImg.frame.origin.y, width: 50, height: 30)
        followings.frame = CGRect(x: width/1.25, y: avaImg.frame.origin.y, width: 50, height: 30)
        
        postsTitle.center = CGPoint(x: posts.center.x, y: posts.center.y + 20)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 20)
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y + 20)
        
        button.frame = CGRect(x: posts.frame.origin.x, y: postsTitle.frame.origin.y + 20, width: width - postsTitle.frame.origin.x - 10, height: 30)
        
        fullnameLbl.frame = CGRect(x: avaImg.frame.origin.x, y: avaImg.frame.origin.y + avaImg.frame.size.height, width: width - 20, height: 30)
        webTxt.frame = CGRect(x: avaImg.frame.origin.x - 5, y: fullnameLbl.frame.origin.y + 15, width: width - 30, height: 30)
        bioLbl.frame = CGRect(x: avaImg.frame.origin.x, y: webTxt.frame.origin.y + 30, width: width - 30, height: 30)
        
        //round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        
    }
    
    
    
        
}
