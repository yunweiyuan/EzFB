//
//  FavoritesViewController.swift
//  EzFB
//
//  Created by Yuan on 4/23/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit

/******** here ********/
class FavEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resultTableView: UITableView!
    
    var prevURL = ""
    var nextURL = ""
    var passId = ""
    var passName = ""
    var passProfileImageURL = ""
    var tableData = [Record]()
    var rawRecords = [Record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        let decoded  = UserDefaults.standard.object(forKey: "eventRecords") as! Data/******** here ********/
        rawRecords = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Record]
        if rawRecords.count <= 10 {
            tableData = rawRecords
        }else {
            nextButton.isEnabled = true
            for i in 0 ..< 10 {
                tableData.append(rawRecords[i])
            }
        }
    }
    @IBAction func previousButtonPressed(_ sender: Any) {
        previousButton.isEnabled = false
        tableData.removeAll()
        for i in 0 ..< 10 {
            tableData.append(rawRecords[i])
        }
        self.resultTableView.reloadData()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        previousButton.isEnabled = true
        tableData.removeAll()
        let size = rawRecords.count
        for i in 10 ..< size {
            tableData.append(rawRecords[i])
        }
        self.resultTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.resultTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource
extension FavEventViewController {/******** here ********/
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavEventCell", for: indexPath) as! FavEventTableViewCell/******** here ********/
        let record = tableData[indexPath.row]
        cell.record = record
        cell.nameLabel.text = record.name
        cell.id = record.id
        let url = URL(string: record.imageURL)
        do {
            let imageData = try Data(contentsOf: url!)
            cell.profileImage.image = UIImage(data: imageData)
        } catch {
            print(error.localizedDescription)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get id
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! FavEventTableViewCell/******** here ********/
        passId = currentCell.id!
        passName = (currentCell.record?.name)!
        passProfileImageURL = (currentCell.record?.imageURL)!
        self.tabBarController?.tabBar.isHidden = true
        performSegue(withIdentifier: "FavEventShowDetails", sender: nil)/******** here ********/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Results"
        navigationItem.backBarButtonItem = backItem
        if segue.identifier == "FavEventShowDetails" {/******** here ********/
            let tabBarC : ShareViewController = segue.destination as! ShareViewController
            let desView: AlbumViewController = tabBarC.viewControllers?.first as! AlbumViewController
            tabBarC.id = passId
            tabBarC.name = passName
            tabBarC.profileImageURL = passProfileImageURL
            tabBarC.type = "event"/************ here ************/
            desView.id = passId
            
        }
    }
    
}

