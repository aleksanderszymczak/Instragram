//
//  followersVC.swift
//  Instragram
//
//  Created by olos on 18.03.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit
import Parse

var showw = String()
var user = String()

class followersVC: UITableViewController {
    
    // arrays to hold data received form servers
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    // array show who do we follow or who following us
    var followArray = [String]()
    


    override func viewDidLoad() {
        super.viewDidLoad()

        // title at the top
        self.navigationItem.title = showw
        
        if showw == "followers" {
            loadFollowers()
        }
        if showw == "followings" {
            loadFollowings()
        }
        
    }

    
    func loadFollowers() {
        
        // STEP 1. Find in FOLLOW class people following user
        // find followers of user
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("following", equalTo: user)
        followQuery.findObjectsInBackground (block: { (objects, error) in
            if error == nil {
                
                // clean up
                self.followArray.removeAll(keepingCapacity: false)
                
                // STEP 2. Hold recived data
                // find related object depending  on query settings
                for object in objects! {
                    self.followArray.append(object.value(forKey: "follower") as! String)
                }
                
                //STEP 3. Find in USER class data of users following "user"
                // find users following user
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        
                        // find related object in User class of Parse
                        for object in objects! {
                            self.usernameArray.append(object.value(forKey: "username") as! String)
                            self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                            self.tableView.reloadData()
                            
                        }
                    } else {
                        print(error?.localizedDescription)
                        
                    }
                })
                
            } else {
                print(error?.localizedDescription)
            }
        })
        
    }

    
    func loadFollowings() {
        
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: user)
        followQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                // clean up
                self.followArray.removeAll(keepingCapacity: false)
                
                // find related objects in "follow" class of Parse
                for object in objects! {
                    
                    self.followArray.append(object.value(forKey: "following") as! String)
                }
                
                // find users followed by user
                let query = PFUser.query()
                query?.whereKey("username", equalTo: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        
                        //clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        
                        // find related objects in "User" class of Parse
                        for object in objects! {
                            
                            self.usernameArray.append(object.value(forKey: "username") as! String)
                            self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                        
                    }else {
                        
                        print(error?.localizedDescription)
                    }
                })
                
            } else {
                
                print(error?.localizedDescription)
            }
        }
        
        
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    
    // cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! followersCell
        
        // connect data from server to objects
        cell.usernameLbl.text = usernameArray[(indexPath as NSIndexPath).row]
        avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
                
            } else {
                print(error?.localizedDescription)
            }
        }

        // show do user following or do not
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.current()!.username!)
        query.whereKey("following", equalTo: cell.usernameLbl.text!)
        query.countObjectsInBackground (block: { (count, error) in
            if error == nil {
                
                if count == 0 {
                    
                    cell.followBtn.setTitle("FOLLOW", for: UIControlState())
                    cell.followBtn.backgroundColor = UIColor.lightGray
                    
                } else {
                    
                    cell.followBtn.setTitle("FOLLOWING", for: UIControlState())
                    cell.followBtn.backgroundColor = UIColor.green
                    
                }
                
            } else {
                print(error?.localizedDescription)
            }
        })
        
        if cell.usernameLbl.text == PFUser.current()?.username {
            
            cell.followBtn.isHidden = true
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! followersCell
        
        // if user tapped on himself then go home, else go guest
        if cell.usernameLbl.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameLbl.text!)
            let guest = storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
            
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
