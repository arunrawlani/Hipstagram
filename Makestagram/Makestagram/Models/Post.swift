//
//  Post.swift
//  Makestagram
//
//  Created by Praynaa Rawlani on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse


//to create a subclass, inherit from PFObject and implement PFSubclassing protocol
class Post : PFObject, PFSubclassing{
    
    var image : UIImage?
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
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
        let imageData = UIImageJPEGRepresentation(image, 0.8)
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
}
