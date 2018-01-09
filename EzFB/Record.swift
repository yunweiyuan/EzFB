//
//  record.swift
//  EzFB
//
//  Created by Yuan on 4/24/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit

class Record:NSObject, NSCoding {
    var imageURL: String = ""
    var name: String = ""
    var id: String = ""
    var image: UIImage = UIImage()
    
    init(imageURL: String, name: String, id: String){
        self.imageURL = imageURL
        self.name = name
        self.id = id
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let imageURL = aDecoder.decodeObject(forKey: "imageURL") as! String
        self.init(imageURL: imageURL, name: name, id: id)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(imageURL, forKey: "imageURL")
    }
}
