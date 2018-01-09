//
//  PostViewController.swift
//  EzFB
//
//  Created by Yuan on 4/25/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class PostViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var resultTableView: UITableView!
    
    
    var json: JSON = [:]
    var image: UIImage = UIImage()
    var tableData = [Post]()
    var monthDict: [String:String] = [
        "01" : "Jan",
        "02" : "Feb",
        "03" : "Mar",
        "04" : "Apr",
        "05" : "May",
        "06" : "Jun",
        "07" : "Jul",
        "08" : "Aug",
        "09" : "Sep",
        "10" : "Oct",
        "11" : "Nov",
        "12" : "Dec"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let barViewControllers = self.tabBarController?.viewControllers
        let svc = barViewControllers![0] as! AlbumViewController
        json = svc.albumJSON
        getPostsFromJSON(json: json)
        resultTableView.rowHeight = UITableViewAutomaticDimension
        resultTableView.estimatedRowHeight = 140
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getPostsFromJSON(json: JSON) {
        tableData.removeAll()
        for result in json["posts"]["data"].arrayValue {
            let content = result["message"].stringValue
            let rawDate = result["created_time"].stringValue
            let date = dateConvertion(date: rawDate)
            let post = Post(content: content, date: date)
            tableData.append(post)
        }
        if tableData.count == 0 {
            warningLabel.alpha = 1
            resultTableView.alpha = 0
        }else{
        let url = json["picture"]["data"]["url"].stringValue
        let imgURL = URL(string: url)
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: imgURL!) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    //print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        self.image = UIImage(data: imageData)!
                        // Do something with your image.
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
        DispatchQueue.main.async{
            self.resultTableView.reloadData()
        }
        }
    }
    
    func dateConvertion(date: String) -> String {
        //2017-04-19T16:24:08+0000 -> 19 Apr 2017 16:24:08
        var formatedDate = ""
        let index = date.index(date.startIndex, offsetBy: 4)
        let year = date.substring(to: index)
        
        var start = date.index(date.startIndex, offsetBy: 8)
        var end = date.index(date.endIndex, offsetBy: -14)
        var range = start..<end
        let day = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 5)
        end = date.index(date.endIndex, offsetBy: -17)
        range = start..<end
        let digit = date.substring(with: range)
        let month = monthDict[digit]
        
        start = date.index(date.startIndex, offsetBy: 11)
        end = date.index(date.endIndex, offsetBy: -5)
        range = start..<end
        let time = date.substring(with: range)
        
        formatedDate = day + " " + month! + " " + year + " " + time
        
        return formatedDate
    }
}

// MARK: - UITableViewDataSource
extension PostViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        let post = tableData[indexPath.row]
        cell.profileImage.image = self.image
        cell.contentLabel.text = post.content
        cell.dataLabel.text = post.date
        return cell
    }
}
