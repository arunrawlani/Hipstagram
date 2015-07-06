//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Arun Rawlani on 6/30/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var photoTakingHelper: PhotoTakingHelper?
    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Fetches follow relationships for current users
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        
        //Using previous query to fetch any posts made by followers of currentUser
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        //Another query to retunr all posts made by the current user
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        
        //creates a query that returns all posts from the previous 2 queries
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        //extracting information to display with the post
        query.includeKey("user")
        query.includeKey("createdAt")
        
        query.findObjectsInBackgroundWithBlock {(result: [AnyObject]?, error: NSError?) -> Void in
            
            //casts to type Post array or just returns an empty array
            self.posts = result as? [Post] ?? []
            //refresh tableView
            self.tableView.reloadData()
    }
    }

    func takePhoto(){
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!){ (image : UIImage?) in
          let post = Post()
            post.image = image
            post.uploadPhoto()
            
            println("Image uploaded. Hips-da-boss!")
        }
    }
    }

    //MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    func  tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        if(viewController is PhotoViewController){
            
            takePhoto()
            return false
        
        }
        else{
            return true
        }
    }
   
}

extension TimelineViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //Table View should have the same amount of rows as the number of posts stored in the array
    return posts.count
}

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! UITableViewCell
    //return a simple placeholder cell with title Post
    cell.textLabel!.text = "Post"
    
    return cell
    }
}
