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
            
            ParseHelper.timelineRequestforCurrentUser {
                (result: [AnyObject]?, error: NSError?) -> Void in
                self.posts = result as? [Post] ?? []
                
                //downloading only the metadata of all posts upfront and deferring image download until displayed
                
                self.tableView.reloadData()
            }
        }


    func takePhoto(){
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!){ (image : UIImage?) in
          let post = Post()
            post.image.value = image
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
    
    //casting cell to the PostTableViewCell class
    let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
    //return a simple placeholder cell with title Post
    
    //using postImage property of our custom view class we decide which image to display
    cell.postImageView.image = posts[indexPath.row].image
    
    
    return cell
    }
}
