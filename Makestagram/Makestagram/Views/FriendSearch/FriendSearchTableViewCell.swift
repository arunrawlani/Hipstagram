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
    
    var canFollow: Bool? = true {
        didSet{
            /*Change state of follow button depending whether it is possible to follow a user or not*/
            if let canFollow = canFollow{
                followButton.selected = !canFollow
            }
        }
    }
    
    @IBAction func followButtonTapped (sender: AnyObject){
        if let canFollow = canFollow where canFollow == true
        delegate?.cell(self, didSelectUnfollowUser: user!)
        }
    }
