//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Arun Rawlani on 6/30/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    var photoTakingHelper: PhotoTakingHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        }
    
    func takePhoto(){
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!){ (image : UIImage?) in
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let imageFile = PFFile(data: imageData)
            imageFile.save()
            
            let post = PFObject(className: "Post")
            post["imageFile"] = imageFile
            post.save()
            
            println("Image uploaded. Hips-da-boss!")
        }
    }
    }

    //MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    func  tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        if(viewController is PhotoViewController){
            
            takePhoto()
            return false
        
        }
        else{
            return true
        }
    }
   
}
