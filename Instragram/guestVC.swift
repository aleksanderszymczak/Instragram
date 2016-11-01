//
//  guestVC.swift
//  Instragram
//
//  Created by olos on 19.09.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit
import Parse

var guestname = [String]()

class guestVC: UICollectionViewController {

    //user interface
    var refresher: UIRefreshControl!
    var page: Int = 10
    
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.alwaysBounceVertical = true
        
        // top title
        self.navigationItem.title = guestname.last
        
        //bacgriund color
        self.collectionView?.backgroundColor = UIColor.white
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(guestVC.back(_:)))

        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guestVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(guestVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // call load posts function
        loadPost()
        
          }
    
    func back(_ sender: UIBarButtonItem) {
        
        //push back
        _ = self.navigationController?.popViewController(animated: true)
        
        //clean guest username or deduct the last guest username from Array
        if !guestname.isEmpty {
            guestname.removeLast()
        }
    }
    
    func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
        
    }
    
    // post loadin function
    func loadPost() {
        
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestname.last!)
        query.limit = page
        query.findObjectsInBackground (block: { (objects, error) in
            
            if error == nil {
                for object in objects! {
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    
                }
                
                self.collectionView?.reloadData()
            } else {
                print(error?.localizedDescription)
            }
            
        })
    }
    
    // cell number
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexpath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        return size
    }
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        
        picArray[(indexPath as NSIndexPath).row].getDataInBackground (block: { (data, error) in
            
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
                
            } else {
                print(error?.localizedDescription)
            }
        })
        return cell
    }
    
    // header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //define header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerView
        
        // STEP 1 - loda data of guests
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestname.last)
        infoQuery.findObjectsInBackground (block: { (objects, error) in
            if error == nil {
                
                // shown wrong user
                if (objects?.isEmpty)! {
                    print("wrong user")
                }
                
                // find related to user information
                for object in objects! {
                    header.fullnameLbl.text = (object.object(forKey: "fullname") as? String)?.localizedUppercase
                    header.bioLbl.text = object.object(forKey: "bio") as? String
                    header.bioLbl.sizeToFit()
                    header.webTxt.text = object.object(forKey: "web") as? String
                    header.webTxt.sizeToFit()
                    let avaFile: PFFile = (object.object(forKey: "ava") as? PFFile)!
                    avaFile.getDataInBackground(block: { (data, error) in
                        if error == nil {
                            header.avaImg.image = UIImage(data: data!)
                        } else {
                            print(error?.localizedDescription)
                        }
                    })
                }
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // STEP 2 - Show do current user follow geust or do not
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()?.username)
        followQuery.whereKey("following", equalTo: guestname.last!)
        followQuery.countObjectsInBackground (block: { (count: Int32, error: Error?) in
            if error == nil {
                if count == 0 {
                    header.button.setTitle("FOLLOW", for: UIControlState.normal)
                    header.button.backgroundColor = UIColor.lightGray
                } else {
                    header.button.setTitle("FOLLOWING", for: UIControlState.normal)
                    header.button.backgroundColor = UIColor.green
                }
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // STEP 3 - Count statistics
        // count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname)
        posts.countObjectsInBackground (block: { (count: Int32, error: Error?) in
            if error == nil {
                header.posts.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        })
        // count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guestname.last!)
        followers.countObjectsInBackground (block: { (count: Int32, error: Error?) in
            if error == nil {
                header.followers.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        })
        // count followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guestname.last!)
        followings.countObjectsInBackground (block: { (count: Int32, error: Error?) in
            if error == nil {
                header.followings.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // STEP 4 - implement tap gesture
        // tap to posts label
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        // tap to followers label
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        // tao to followings label
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        
        
        return header
    }
    
    
    func postsTap() {
        if !picArray.isEmpty {
            let index = NSIndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index as IndexPath, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    func followersTap() {
        user = guestname.last!
        showw = "followers"
        
        // define followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        //navigate to it
        self.navigationController?.pushViewController(followers, animated: true)
        
        
    }
    
    func followingsTap() {
        user = guestname.last!
        showw = "followings"
        
        // define followingsVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        //navigate to it 
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    
}
