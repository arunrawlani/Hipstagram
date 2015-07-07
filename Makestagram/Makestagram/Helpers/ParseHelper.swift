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
    
    // Following Relation
    static let ParseFollowClass       = "Follow"
    static let ParseFollowFromUser    = "fromUser"
    static let ParseFollowToUser      = "toUser"
    
    // Like Relation
    static let ParseLikeClass         = "Like"
    static let ParseLikeToPost        = "toPost"
    static let ParseLikeFromUser      = "fromUser"
    
    // Post Relation
    static let ParsePostUser          = "user"
    static let ParsePostCreatedAt     = "createdAt"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass    = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    static func timelineRequestforCurrentUser(completionBlock: PFArrayResultBlock){
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseLikeFromUser, equalTo: PFUser.currentUser()!)
        
        //Using previous query to fetch any posts made by followers of currentUser
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        //Another query to retunr all posts made by the current user
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        //creates a query that returns all posts from the previous 2 queries
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        //extracting information to display with the post
        query.includeKey(ParsePostUser)
        query.includeKey(ParsePostCreatedAt)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    
    }
    
  
    //MARK: Likes
    static func likePost(user: PFUser, post: Post){
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, post: Post) {
        // forming a query to find like of a given user that belongs to a given post
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let error = error{
                ErrorHandling.defaultErrorHandler(error)
            }
            
            // iterating over all objects that meet requirements and delete them
            if let results = results as? [PFObject] {
                for likes in results {
                    likes.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    static func likesForPost(post: Post, completionBlock: PFArrayResultBlock){
        //ArrayResultBlock has signature of type ([AnyObject]?, NSError?) -> Void. This is the deafult signature of most callbacks in Parse queries so we are able to easily send the background method.
        //forms a query for likeObjects
        let query = PFQuery(className: ParseLikeClass)
        
        //fetches all likes on the post
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        //using includeKey to tell Parse to fetch user for each of the likes
        query.includeKey(ParseLikeFromUser)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
}
}

extension PFObject: Equatable{
    
}
public func ==(lhs: PFObject, rhs: PFObject) -> Bool{
    return lhs.objectId == rhs.objectId
}