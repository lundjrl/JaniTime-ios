//
//  AccountViewController.swift
//  JaniTime
//
//  Created by James Lund on 1/30/20.
//  Copyright © 2020 Sidharth J Dev. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation
import GoogleMaps
import RealmSwift
import Toast_Swift
import UICircularProgressRing
//import HomeViewController

class AccountViewController: UIViewController{
    
    var animationSize: CGFloat = 0.1

        @IBOutlet weak var clearButton: UIButton!
        
//        func viewDidAppear(_ animated: Bool) {
//            if JaniTime.user.client_company != "" {
//                titleLabel.text = JaniTime.user.client_company
//            } else {
//                titleLabel.text = "Home"
//            }
//            dispatchedWarningNotification = false
//        }
        
    @IBAction func clearAct(_ sender: Any) {
            clearAlert()
        }
    
    func clearAlert() {
        let clearAlert = UIAlertController(title: "Logout", message: "Are you sure you want to log out of the app?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.clearConfirmed()
        }
        
        let noAction = UIAlertAction(title: "No", style: .destructive) { (action) in
            
        }
        clearAlert.addAction(yesAction)
        clearAlert.addAction(noAction)
        
        present(clearAlert, animated: true, completion: nil)
        
    }
    
    func clearConfirmed() {
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            let domain = Bundle.main.bundleIdentifier!
            JaniTime.userDefaults.removePersistentDomain(forName: domain)
            JaniTime.parsingData.punchingHistory.removeAll()
            JaniTime.userDefaults.synchronize()
            self.view.showLoaderAnimation(loaderType: .loading, message: "Resetting", animationViewSizeMultiplier: animationSize)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                JaniTime.appDelegate.resetAppToFirstController(sBID: Constants.StoryBoardID.initialVC)
            }
    //        getCompanyList()
        }
}
