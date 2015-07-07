//
//  Post.swift
//  Makestagram
//
//  Created by Arun Rawlani on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond


//to create a subclass, inherit from PFObject and implement PFSubclassing protocol
class Post : PFObject, PFSubclassing{
    
    var image : Dynamic<UIImage?> = Dynamic(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    var likes =  Dynamic<[PFUser]?>(nil)
    //making likes dynamic so to listen to changes and update UI after downloading lazily
    //optional because before downloading, this property will be nill
    
    //Defining each property to access on Parse.
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    //MARK: Subclassing Protocol
    
    
    //By implementing parseClassName, a connection between Swift and Parse is created
    static func parseClassName() -> String {
        return "Post"
    }
    
    //pure boilerplate code. Copy paste in most projects
    override init () {
        super.init()
    }
    
    override class func initialize(){
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken){
            //inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    func uploadPhoto(){
        //Get photo from image property and change it to a PFFile and then upload
        let imageData = UIImageJPEGRepresentation(image.value, 0.8)
        let imageFile = PFFile(data: imageData)
        imageFile.saveInBackgroundWithBlock(nil)
       
        //As soon as photo gets uploaded start background task
        //API requires to provide expiration handler in form of closure
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            //this is called in case the task is not successful, then we are required to cancel it
            //and then return the resources we created
        }
        
        // 2
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            // 3
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        
        //any post should be associated with a user
        user = PFUser.currentUser()
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil) //the nil refers to a callback that can execute code once upload is done
    }
    
    func downloadImage(){
        //if image is not downloaded yet, get it
        //We check if value is nil, because images may be downloaded multiple times and a non-nil may give an error
        if (image.value == nil){
            
            // We start the download here in background
            imageFile?.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?)-> Void in
                if let data = data {
                    
                    let image = UIImage (data: data, scale: 1.0)!
                    //once download is complete, we update post.image using the .value as image is dynamic
                    self.image.value = image
                }
        }
    }
}
    
    func fetchLikes() {
        //if not nil we used the cached value, until the timeline is refreshed
        if (likes.value != nil) {
            return
        }
        
        //fetch likes for current Post using method of ParseHelper created earlier
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            
            //filter method takes a closure and returns object from original array that meet the requirement stated. So filter to remove likes of users that no longer exist
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
             /* maps take a closure that is called for each element and returns a new array as result. However, unlike filter map doesnt remove but replaces objects. We get an array of users from array of likes */
            self.likes.value = likes?.map { like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return contains(likes, user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser){
        if (doesUserLikePost(user)){
            //if image is liked, unlike it
            //remove user using filter and then removing like and syncing with Parse
            likes.value = likes.value?.filter { $0 != user}
            ParseHelper.unlikePost(user, post: self)
        }
        else{
            //append user if not liked, and then add to local cache and sync with Parse
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
}
