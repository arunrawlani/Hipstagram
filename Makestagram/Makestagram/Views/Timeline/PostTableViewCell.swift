//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Arun Rawlani on 7/5/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Bond

class PostTableViewCell: UITableViewCell{
    
    @IBOutlet weak var postImageView: UIImageView!
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