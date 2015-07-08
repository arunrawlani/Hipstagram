//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Arun Rawlani on 6/30/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    
    @IBOutlet weak var tableView: UITableView!
    var photoTakingHelper: PhotoTakingHelper?
    
    //showing the latest 5 posts index 0 to 4
    let defaultRange = 0...4
    //additional 5 pots once we reach the end
    let additionalRangeSize = 5
    
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!

    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        
        //start by calling this method to take in the range argument
        ParseHelper.timelineRequestforCurrentUser(range){
            (result: [AnyObject]?, error: NSError?) -> Void in
            
            //we check to see if we have received a value or nil
            let posts = result as? [Post] ?? []
            
            //we call
            completionBlock(posts)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
        }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
            
         timelineComponent.loadInitialIfRequired()
        
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


extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
}

extension TimelineViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //Table View should have the same amount of rows as the number of posts stored in the array
    return timelineComponent.content.count
}
   

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    //casting cell to the PostTableViewCell class
    let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
    //return a simple placeholder cell with title Post
    
    let post = timelineComponent.content[indexPath.row]
    //directly before a post is displayed, we trigger the image download
    post.downloadImage()
    post.fetchLikes()
    //assigning post to be displayed
    cell.post = post
    
    return cell
    }
}
