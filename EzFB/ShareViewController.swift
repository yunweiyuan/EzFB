//
//  ShareViewController.swift
//  EzFB
//
//  Created by Yuan on 4/26/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit


class ShareViewController : UITabBarController, FBSDKSharingDelegate{
    var isAdded: Bool? = nil
    var id = ""
    var type = ""
    var name = ""
    var profileImageURL = ""
    var favOption = ""
    
    @IBOutlet weak var menu: UIBarButtonItem!
    
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Menu", preferredStyle: .actionSheet)
        if isAdded != nil{
            if self.isAdded! {
                self.favOption = "Remove from favorites"
            } else {
                self.favOption = "Add to favorites"
            }
        } else {
            favOption = self.getFavOption()
        }
        
        alert.addAction(UIAlertAction(title: favOption, style: .default) { action in
            // perhaps use action.title here
            self.favoriteHandle()
        })
        
        alert.addAction(UIAlertAction(title: "Share", style: .default) { action in
            // perhaps use action.title here
            self.shareToFB()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
            // perhaps use action.title here
        })

        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getFavOption() -> String {
        let key = type + "Records"
        let decoded  = UserDefaults.standard.object(forKey: key) as! Data
        let records = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Record]
        if records.contains(where: {$0.id == self.id}) {
            self.isAdded = true
            return "Remove from favorites"
        }else {
            self.isAdded = false
            return "Add to Favorites"
        }
    }
    
    func favoriteHandle() {
        let key = type + "Records"
        if isAdded! {
            isAdded = false
            let decoded  = UserDefaults.standard.object(forKey: key) as! Data
            var records = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Record]
            let idx = records.index(where: {$0.id == self.id})
            records.remove(at: idx!)
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: records)
            UserDefaults.standard.set(encodedData, forKey: key)
            UserDefaults.standard.synchronize()
            self.showToast(message: "Removed from favorites!")
        } else {
            isAdded = true
            let record = Record(imageURL: self.profileImageURL, name: self.name, id: self.id)
            let decoded  = UserDefaults.standard.object(forKey: key) as! Data
            var records = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Record]
            records += [record]
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: records)
            UserDefaults.standard.set(encodedData, forKey: key)
            UserDefaults.standard.synchronize()
            self.showToast(message: "Added to favorites!")
        }
        
    }
    
    func shareToFB() {
        let myContent: FBSDKShareLinkContent = FBSDKShareLinkContent()
        myContent.contentTitle = name
        myContent.contentDescription = "FB Share for CSCI 571"
        myContent.imageURL = URL(string: profileImageURL)
        let shareDialog:FBSDKShareDialog = FBSDKShareDialog()
        shareDialog.shareContent = myContent
        shareDialog.delegate = self
        shareDialog.mode = .feedBrowser
        shareDialog.fromViewController = self
        shareDialog.show()
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("shared")
        let when = DispatchTime.now() + 1 // change 1 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.showToast(message: "Shared")
        }
    }
    
    
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        
    }
    
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("cancelled")
        self.showToast(message: "Cancelled")
    }
    
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 4;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.2, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.99
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

