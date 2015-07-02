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
}
