//
//  AlbumViewController.swift
//  EzFB
//
//  Created by Yuan on 4/25/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class AlbumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var resultTableView: UITableView!
    

    var id = ""
    var albumJSON:JSON = [:]
    var tableData = [Album]()
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("is id passed \(id)")
        SwiftSpinner.show("Loading data...")
        fetchJSON(id: id)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchJSON(id: String) {
        let url = URL(string: "http://sample-env-1.ahqhkmvghw.us-west-2.elasticbeanstalk.com/fb.php?var_id=\(id)")!
        Alamofire.request(url).responseJSON{ response in
            let json = JSON(response.result.value ?? [:])
            self.albumJSON = json
            self.getAlbumsFromJSON(json: self.albumJSON)
        }
    }
    
    func getAlbumsFromJSON(json: JSON) {
        tableData.removeAll()
        for result in json["albums"]["data"].arrayValue {
            let url_1 = result["photos"]["data"][0]["picture"].stringValue
            let url_2 = result["photos"]["data"][1]["picture"].stringValue
            let name = result["name"].stringValue
            
            let album = Album(name: name, imageURL_1: url_1, imageURL_2: url_2)
            tableData.append(album)
        }
        if tableData.count == 0 {
            warningLabel.alpha = 1
            resultTableView.alpha = 0
        }
        DispatchQueue.main.async{
            self.resultTableView.reloadData()
            SwiftSpinner.hide()
        }
    }
    
    
}

// MARK: - UITableViewDataSource
extension AlbumViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumTableViewCell
        let album = tableData[indexPath.row]
        let url_1 = URL(string: album.imageURL_1)
        let url_2 = URL(string: album.imageURL_2)
        cell.albumNameLabel.text = album.name
        do {
            if url_1 != nil {
                let imageData_1 = try Data(contentsOf: url_1!)
                cell.image_1.image = UIImage(data: imageData_1)
            }
        } catch {
            print(error.localizedDescription)
        }
        do {
            if url_2 != nil {
                let imageData_2 = try Data(contentsOf: url_2!)
                cell.image_2.image = UIImage(data: imageData_2)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! AlbumTableViewCell).watchFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! AlbumTableViewCell).ignoreFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return AlbumTableViewCell.expandedHeight
        } else {
            return AlbumTableViewCell.defaultHeight
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        var indexPaths: Array<IndexPath> = []
        if let previous = previousIndexPath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        
        if indexPaths.count > 0 {
            tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
        }
 
    }
}
