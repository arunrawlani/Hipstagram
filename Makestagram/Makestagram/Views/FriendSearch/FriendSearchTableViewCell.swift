//
//  FriendSearchTableViewCell.swift
//  Makestagram
//
//  Created by Arun Rawlani on 7/8/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

protocol FriendSearchTableViewCellDelegate: class{
    func cell(cell:FriendSearchTableViewCell, didSelectFollowUser user: PFUser)
    func cell(cell:FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser)
}

class FriendSearchTableViewCell: UITableViewCell{
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var usernamelabel: UILabel!
    weak var delegate: FriendSearchTableViewCellDelegate?
    
    var user: PFUser? {
        didSet{
            usernamelabel.text = user?.username
        }
    }
    
    
    
    @IBAction func followButtonTapped (sender: AnyObject){
        
        }
    }
