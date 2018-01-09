//
//  homeViewController.swift
//  EzFB
//
//  Created by Yuan on 4/23/17.
//  Copyright © 2017 Yuan. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var location: CLLocation!
    var keyword = ""
    var center = ""
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var keywordText: UITextField!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: "resignKeyboard")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        


        if UserDefaults.standard.object(forKey: "pageRecords") == nil {
            let encodedDataq: Data = NSKeyedArchiver.archivedData(withRootObject: [])
            let encodedDataw: Data = NSKeyedArchiver.archivedData(withRootObject: [])
            let encodedDatae: Data = NSKeyedArchiver.archivedData(withRootObject: [])
            let encodedDatar: Data = NSKeyedArchiver.archivedData(withRootObject: [])
            let encodedDatat: Data = NSKeyedArchiver.archivedData(withRootObject: [])
            UserDefaults.standard.set(encodedDataq, forKey:"userRecords")
            UserDefaults.standard.set(encodedDataw, forKey:"pageRecords")
            UserDefaults.standard.set(encodedDatae, forKey:"eventRecords")
            UserDefaults.standard.set(encodedDatar, forKey:"placeRecords")
            UserDefaults.standard.set(encodedDatat, forKey:"groupRecords")
            UserDefaults.standard.synchronize()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearText(_ sender: Any) {
        keywordText.text = ""
    }

    @IBAction func getResult(_ sender: Any) {
        if keywordText.text?.isEmpty ?? true {
            showToast(message: "Enter a valid query!")
        }else {
            keyword = keywordText.text!.replacingOccurrences(of: " ", with: "+")
            center = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            UserDefaults.standard.set(keyword, forKey: "keyword")
            UserDefaults.standard.set(center, forKey: "center")
            UserDefaults.standard.synchronize()
            performSegue(withIdentifier: "tabViewSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if segue.identifier == "tabViewSegue" {
            let tabBarC : UITabBarController = segue.destination as! UITabBarController
            let midNavC : UINavigationController = tabBarC.viewControllers?.first as! UINavigationController
            let desView: UserViewController = midNavC.viewControllers.first as! UserViewController
            keyword = keywordText.text!.replacingOccurrences(of: " ", with: "+")
            desView.keyword = "\(keyword)"
            center = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            desView.center = center
        }
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
    
    /**
     Resign keyboard
     */
    func resignKeyboard() {
        keywordText.resignFirstResponder()
    }
    
}
// MARK: - UIGestureRecognizerDelegate

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view, view is UIControl {
            return false
        }
        return true
    }
    
}

