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
            }
        }
    }
}