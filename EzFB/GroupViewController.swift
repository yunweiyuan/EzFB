//
//  PageViewController.swift
//  EzFB
//
//  Created by Yuan on 4/27/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

//********** here ************//
class GroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    
    var keyword = ""
    var center = ""
    var prevURL = ""
    var nextURL = ""
    var passId = ""
    var passName = ""
    var passProfileImageURL = ""
    var tableData = [Record]()
    //********** here ************//
    //var userJSON:JSON = [:]
    //var pageJSON:JSON = [:]
    //var eventJSON:JSON = [:]
    //var placeJSON:JSON = [:]
    var groupJSON:JSON = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.resultTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        SwiftSpinner.show("Loading data...")
        // Do any additional setup after loading the view.
        keyword = UserDefaults.standard.object(forKey: "keyword") as! String
        center = UserDefaults.standard.object(forKey: "center") as! String
        fectchJSON(keyword: keyword, center: center)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        JSONFromURL(url: nextURL)
    }
    
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        JSONFromURL(url: prevURL)
    }
    
    
    func JSONFromURL(url: String) {
        let newURL = URL(string: url) ?? URL(string: "")
        Alamofire.request(newURL!).responseJSON{ response in
            var json = JSON(response.result.value!)
            //print("json \(json)")
            if(json["paging"]["previous"].exists()){
                self.prevURL = json["paging"]["previous"].stringValue
                self.prevButton.isEnabled = true
            } else {
                self.prevButton.isEnabled = false
            }
            if(json["paging"]["next"].exists()){
                self.nextURL = json["paging"]["next"].stringValue
                self.nextButton.isEnabled = true
            } else {
                self.nextButton.isEnabled = false
            }
            self.groupJSON = json//********** here ************//
            self.getRecordFromJSON(json: self.groupJSON)//********** here ************//
        }
    }
    
    func fectchJSON(keyword: String, center: String) {
        let url = URL(string: "http://sample-env-1.ahqhkmvghw.us-west-2.elasticbeanstalk.com/fb.php?var_k="+keyword+"&var_c="+center)!
        Alamofire.request(url).responseJSON{ response in
            var json = JSON(response.result.value!)
            print("Get JSON success")
            //self.userJSON = json["user"]
            //self.pageJSON = json["page"]//********** here ************//
            //self.eventJSON = json["event"]
            //self.placeJSON = json["place"]
            self.groupJSON = json["group"]
            //print(json["user"])
            if(json["group"]["paging"]["previous"].exists()){//********** here ************//
                self.prevURL = json["group"]["paging"]["previous"].stringValue//********** here ************//
            }
            if(json["group"]["paging"]["next"].exists()){//********** here ************//
                self.nextURL = json["group"]["paging"]["next"].stringValue//********** here ************//
            }
            self.getRecordFromJSON(json: self.groupJSON)
        }
    }
    
    func getRecordFromJSON(json: JSON) {
        tableData.removeAll()
        for result in json["data"].arrayValue {
            let imageURL = result["picture"]["data"]["url"].stringValue
            let name = result["name"].stringValue
            let id = result["id"].stringValue
            let record = Record(imageURL: imageURL, name: name, id: id)
            tableData.append(record)
        }
        DispatchQueue.main.async{
            self.resultTableView.reloadData()
            SwiftSpinner.hide()
        }
    }
}

// MARK: - UITableViewDataSource
extension GroupViewController {            //********** here ************//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupTableViewCell//********** here ************//
        let record = tableData[indexPath.row]//********** here ************//
        let decoded  = UserDefaults.standard.object(forKey: "groupRecords") as! Data//********** here ************//
        let records = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Record]
        if records.contains(where: {$0.id == record.id}) {
            let filled = UIImage(named: "filled")
            cell.favButton.setImage(filled, for: .normal)
        }else{
            let empty = UIImage(named: "empty")
            cell.favButton.setImage(empty, for: .normal)
        }
        
        let imgURL = URL(string: record.imageURL)
        cell.nameLabel.text = record.name
        cell.id = record.id
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
                        let image = UIImage(data: imageData)
                        // Do something with your image.
                        record.image = image!
                        cell.profileImage.image = image
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
        cell.record = record
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get id
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! GroupTableViewCell//********** here ************//
        passId = currentCell.id!
        passName = (currentCell.record?.name)!
        passProfileImageURL = (currentCell.record?.imageURL)!
        self.tabBarController?.tabBar.isHidden = true
        performSegue(withIdentifier: "GroupShowDetails", sender: nil)//********** here ************//
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Results"
        navigationItem.backBarButtonItem = backItem
        if segue.identifier == "GroupShowDetails" {//********** here ************//
            let tabBarC : ShareViewController = segue.destination as! ShareViewController
            let desView: AlbumViewController = tabBarC.viewControllers?.first as! AlbumViewController
            tabBarC.id = passId
            tabBarC.name = passName
            tabBarC.profileImageURL = passProfileImageURL
            tabBarC.type = "group"//********** here ************//
            desView.id = passId
            
        }
    }
    
}
