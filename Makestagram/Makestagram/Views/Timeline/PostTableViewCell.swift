//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Arun Rawlani on 7/5/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Bond
import Parse

class PostTableViewCell: UITableViewCell{
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    //Defining a bond is similar to Dynamic in which the object inside angled brackets is the type of info we receive from it. In this case its an optional array of PFUsers
    var likeBond: Bond<[PFUser]?>!
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
        /*create a new bond with same type as likeBond property. Takes a trailing closure with code that si executed everytime it receives a new value. Bond receives list of users that have liked a post in likedList */
        /* using unowned self because bond is created by class so has strong reference. The bond's closure refers to self and creates strong reference to class creating a retain cycle. Unowned prevents strong references from being created*/
        likeBond = Bond<[PFUser]?>(){ [unowned self] likeList in
            //checks if the value of likes on a post has changed. We check if we have received a value or nil
            if let likeList = likeList{
                
                //recieved a value not a nil, so perform updates
                
                //display usernames that have liked the post
                self.likesLabel.text = self.stringFromUserList(likeList)
                
                //changes like button to red when selected
                self.likeButton.selected = contains(likeList, PFUser.currentUser()!)
                
                //if no one has liked the post, we hide the small heart
                self.likesIconImageView.hidden = (likeList.count == 0)
            }
            //if value received is nil
            else{
                self.likesLabel.text = ""
                self.likeButton.selected = false
                self.likesIconImageView.hidden = true
            }
    }
    }
    
    func stringFromUserList(userList: [PFUser]) -> String{
        
        //mapping from PFUsers to usernames of these PFObjects
        let usernameList = userList.map { user in user.username! }
        
        let commaSeperatedList = ", ".join(usernameList)
        
        return commaSeperatedList
        
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject){
        
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject){
        post?.toggleLikePost(PFUser.currentUser()!)
        
    }
    
    var post : Post?{
        didSet{
            
            //whenever a new value is assigned to post property, we check if the value is nil usuing optional binding
            if let post = post{
                //if it isnt nil, we bind as stated below
                //bind the image of the post to the 'postImage' view
                post.image ->> postImageView
                
                //bond likeBond, to update button and label
                post.likes ->> likeBond
            }
        }
    }
}