//
//  FavUserTableViewCell.swift
//  EzFB
//
//  Created by Yuan on 4/27/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit

class FavPlaceTableViewCell: UITableViewCell {/******** here ********/
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    
    
    
    var record: Record?
    var id: String?
    
    @IBAction func favButtonPressed(_ sender: Any) {
        if let record  = record {
            showJoinAnimation()
            storePlace(cell: self, record: record)/******** here ********/
        }
    }
    
    func showJoinAnimation() {
        let empty = UIImage(named: "empty")
        let filled = UIImage(named: "filled")
        if (favButton.currentImage?.isEqual(empty))! {
            favButton.setImage(filled, for: .normal)
        }else {
            favButton.setImage(empty, for: .normal)
        }
    }
    
    func storePlace(cell: FavPlaceTableViewCell, record: Record) {/******** here ********/
        //get the records
        let decoded  = UserDefaults.standard.object(forKey: "placeRecords") as! Data/******** here ********/
        var records = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Record]
        if records.contains(where: {$0.id == record.id}) {
            let idx = records.index(where: {$0.id == record.id})
            records.remove(at: idx!)
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: records)
            UserDefaults.standard.set(encodedData, forKey: "placeRecords")/******** here ********/
            UserDefaults.standard.synchronize()
        }else {
            //update and store the records
            records += [record]
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: records)
            UserDefaults.standard.set(encodedData, forKey: "placeRecords")/******** here ********/
            UserDefaults.standard.synchronize()
        }
        
    }
    
}
