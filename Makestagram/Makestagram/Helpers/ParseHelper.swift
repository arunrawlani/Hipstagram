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
    
    static func timelineRequestforCurrentUser(range: Range<Int>, completionBlock: PFArrayResultBlock){
       
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
        
        //skip defines how may elements that match our query will be skipped
        query.skip = range.startIndex
        
        //limit defines how many elements do we want to load
        query.limit = range.endIndex - range.startIndex
        
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
    //MARK: Likes
    
    /**
    Fetches all users that the following users is following.
    
    :param: user The user whose followees you want to retrieve 
    :param: completionBlock The completion block that is called when the query completes
    **/
    static func getFollowingUsersForUser(user: PFUser, completionBlock: PFArrayResultBlock){
        let query = PFQuery(className: ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
    Establishes a follow relationship between 2 users.

    :param: user The user that is following
    :param: toUser The user that is
    **/
    
    static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser){
        let followObject = PFObject(className: ParseFollowClass)
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        
        followObject.saveInBackgroundWithBlock(nil)
    }
    
    /**
    Deletes a follow relationship between 2 users.

    :param: user The user that is following
    :param: toUser The user that is going to be unfollowed

    **/
    
    static func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: ParseFollowClass)
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.whereKey(ParseFollowToUser, equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for follow in results {
                follow.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    
    //MARK: Users
    
    /**
    Fetch all users, except the one currently signed in.
    Limits the amount of users returned to 20.

    :param: completionBlock The completion block is called when the query is done
    :returns: The generated PFQuery
    **/
    
    static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!
        //exclude the current user
        
        query.whereKey(ParseHelper.ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    /**
    Fetch users whose name matches the search term provided

    :param: searchText The text entered in search bar
    :completionBlock: The completion block is called when the query is done

    :return: returns the generated PFQuery
    **/
    
    static func searchUsers(searchText:String, completionBlock: PFArrayResultBlock) -> PFQuery{
        /*
        Performing Regex to make it insensitive to case. However, this may make it slow in large databases
        */
        let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername, matchesRegex: searchText, modifiers: "i")
        
        query.whereKey(ParseHelper.ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        return query
        
    }
    
    
}

extension PFObject: Equatable{
    
}
public func ==(lhs: PFObject, rhs: PFObject) -> Bool{
    return lhs.objectId == rhs.objectId
}