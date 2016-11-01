//
//  homeVC.swift
//  Instragram
//
//  Created by olos on 06.03.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit
import Parse


class homeVC: UICollectionViewController {
        
    
    
    @IBAction func logOut(_ sender: AnyObject) {
        
        PFUser.logOutInBackground { (error) in
            if error == nil {
                
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                let signIn = self.storyboard?.instantiateViewController(withIdentifier: "signinVC") as! signinVC
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signIn
            }
        }
        
    }
    
    var refresher: UIRefreshControl!
    
    // size of page
    var page: Int = 10
    
    var uuidArray = [String]()
    var picArray = [PFFile]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //always scroll vertical
        self.collectionView?.alwaysBounceVertical = true
        
        // background color
        collectionView?.backgroundColor = UIColor.white
        
        // title at the top
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        
        // recive notification form editVC
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        // load posts function
        loadPosts()
        
    }
    
    // refresher function
    func refresh() {
        
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    
    // load posts function
    func loadPosts(){
        
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        query.limit = page
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
            } else {
                
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
                self.collectionView?.reloadData()
            }
        })
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }
    
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexpath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        return size
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        
        // get picture form the picArray
        picArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }else {
                
                cell.picImg.image = UIImage(data: data!)
            }
        }
        
    return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerView
        // STEP 1. Get user data
        header.fullnameLbl.text = (PFUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.webTxt.text = PFUser.current()?.object(forKey: "web") as? String
        header.webTxt.sizeToFit()
        header.bioLbl.text = PFUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        header.button.setTitle("edit profile", for: UIControlState())
        
        let avaQuery = PFUser.current()?.object(forKey: "ava") as? PFFile
        avaQuery?.getDataInBackground(block: { (data, error) -> Void in
            if error != nil {
                print(error)
            } else {
                
                header.avaImg.image = UIImage(data: data!)
                
            }
            
        })
        // STEP 2. Count statistics
        // count total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: (PFUser.current()!.username)!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error != nil{
                
                print(error?.localizedDescription)
                
            }else{
                
            header.posts.text = "\(count)"
                
            }
        })
        
        // count total followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: (PFUser.current()!.username)!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error != nil {
                
                print(error?.localizedDescription)
            } else {
                
                header.followers.text = "\(count)"
            }
        })
        
        
        // count total followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: (PFUser.current()!.username)!)
        followings.countObjectsInBackground (block: { (count, error) -> Void in
            if error != nil {
                
                print(error?.localizedDescription)
            } else {
                
                header.followings.text = "\(count)"
            }
        })
        
        // STEP 3. Implement Tap Gestures
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.addGestureRecognizer(followingsTap)
        
        
        return header
        
    }
    
    // tapped post label
    func postsTap(){
        
        if !picArray.isEmpty {
            
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    // tapped followers label
    func followersTap(){
        
        user = PFUser.current()!.username!
        showw = "followers"
        
        // make referrences to followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    // tapped followings label
    func followingsTap(){
        
        user = PFUser.current()!.username!
        showw = "followings"
        
        // make references to followingsVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        //present
        self.navigationController?.pushViewController(followings, animated: true)
        

    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
