//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Praynaa Rawlani on 7/6/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper{
    
    static func timelineRequestforCurrentUser(completionBlock: PFArrayResultBlock){
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
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    
    }
}
