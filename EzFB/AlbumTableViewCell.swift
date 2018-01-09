//
//  AlbumTableViewCell.swift
//  EzFB
//
//  Created by Yuan on 4/25/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var image_1: UIImageView!
    @IBOutlet weak var image_2: UIImageView!
    
    class var expandedHeight: CGFloat { get {return 550 } }
    class var defaultHeight: CGFloat { get {return 44 } }
    
    var frameAdded = false
    
    func checkHeight() {
        let hidden = (frame.size.height < AlbumTableViewCell.expandedHeight)
        image_1.isHidden = hidden
        image_2.isHidden = hidden
    }
    
    func watchFrameChanges() {
        if !frameAdded {
            addObserver(self, forKeyPath: "frame", options: .new, context: nil)
            checkHeight()
            frameAdded = true
        }
    }
    
    func ignoreFrameChanges() {
        if frameAdded {
            removeObserver(self, forKeyPath: "frame")
            frameAdded = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    
    
    deinit {
        ignoreFrameChanges()
    }
}
