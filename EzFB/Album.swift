//
//  Album.swift
//  EzFB
//
//  Created by Yuan on 4/25/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit

class Album {
    var imageURL_1: String = ""
    var imageURL_2: String = ""
    var name: String = ""

    
    init(name: String, imageURL_1: String, imageURL_2: String){
        self.imageURL_1 = imageURL_1
        self.imageURL_2 = imageURL_2
        self.name = name
    }
}
