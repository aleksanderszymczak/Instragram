//
//  followersCell.swift
//  Instragram
//
//  Created by olos on 18.03.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit
import Parse

class followersCell: UITableViewCell {
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    
    @IBAction func followBtn_click(_ sender: AnyObject) {
        
        let title = followBtn.title(for: UIControlState())
        
        //to follow
        if title == "FOLLOW" {
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = usernameLbl.text
            object.saveInBackground(block: { (success, error) in
                
                if success {
                    
                    self.followBtn.setTitle("FOLLOWING", for: UIControlState())
                    self.followBtn.backgroundColor = UIColor.green
                    
                } else {
                    
                    print(error?.localizedDescription)
                }
            })
            // unfollow
        } else {
            
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: (PFUser.current()?.username)!)
            query.whereKey("following", equalTo: usernameLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) in
                
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if success {
                                self.followBtn.setTitle("FOLLOW", for: UIControlState())
                                self.followBtn.backgroundColor = UIColor.lightGray
                                
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
        // Initialization code
        
        // alignment
        let width = UIScreen.main.bounds.width
        avaImg.frame = CGRect(x: 10, y: 10, width: width / 5.3, height: width / 5.3)
        usernameLbl.frame = CGRect(x: avaImg.frame.size.width + 20, y: 30, width: width / 3.2, height: 30)
        followBtn.frame = CGRect(x: width / 3.5 - 10, y: 30, width: width / 3.5, height: 30)
        
        
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
