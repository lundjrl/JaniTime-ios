//
//  MessageViewController.swift
//  JaniTime
//
//  Created by James Lund on 9/16/20.
//  Copyright © 2020 Sidharth J Dev. All rights reserved.
//

import Foundation

import UIKit

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Init message tableview
    @IBOutlet var messagesTable: UITableView!
    
    let api = API()
    
    var delegate: DataEntryDelegate? = nil
    
    // Change native UI to be what we want when screen is generated.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        messagesTable.delegate = self
        messagesTable.dataSource = self
        
        print("Messages screen loaded")
        
        let messageNib = UINib(nibName: "MessageCell", bundle: nil)
        
        messagesTable.register(messageNib, forCellReuseIdentifier: "MessageCell")
        
        // Init table UI features
        messagesTable.allowsSelection = false // ?
        messagesTable.separatorStyle = .none
        messagesTable.bounces = false
        
        // Can set estimated row height if needed to here.
        // messagesTable.estimatedRowHeight = 175.0
        // messagesTable.rowHeight = UITableView.automaticDimension
        
        getEmployerMessages()
        
    }
    
    // Do something when onFocus listener fires off
    @objc func appMovedToForeground(){
        print("App is in Foreground")
        
    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        print("View reappeared")
        getEmployerMessages()
    }
    
    // TableView stuff here
    
    // Display
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If tablesize is empty
        print("Tablesize: \(section)")
        return 3
        
//        if section == 0 {
//            return 1
//        } else {
//            // Return size of table here.
//            return JaniTime.parsingData.messages.count
//        }
        
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            // Do something if table is empty
//            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: messagesTable.frame.size.width, height: 0))
//            headerView.backgroundColor = .clear
//            return headerView
//        } else {
//            // Do something else if table is not empty
//            // TODO: constrain margins here for table
//            return nil
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView()
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cell for row at called")
        // Do stuff here?
        if let messageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell {
            messageCell.messageTitle.text = "Data"
            messageCell.messageDate.text = "09-17-2020"
            messageCell.messageBody.text = "Body"
            
            return messageCell

        } else {
            return UITableViewCell()
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 350
//        } else {
//            return 100.0
//        }
//    }
    
    // End table stuff
    
    // Call to get message data from API
    func getEmployerMessages() {
        let params: [String : Int] = ["user_id": Int(JaniTime.user.user_id) ?? 0, "client_id": Int(JaniTime.user.client_id)! ]
        
        api.callAPI(params: params, APItype: .messages, APIMethod: .post) { (message, status) in
            print("Status: \(status)")
            print("Message: \(message)")
            // Need to parse message object here or only grab the last body of text and throw it into local storage.
            if status {
                self.saveLastMessage(message: message)
                DispatchQueue.main.async {
                    self.messagesTable.reloadData()
                }
            } else {
                print("Message Failed.")
                self.saveLastMessage(message: "Hello")
            }
        }
    }
    
    // When user refreshes screen, scroll to top.
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.messagesTable.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // Save last employer message to local data
    func saveLastMessage(message: String){
        print("IN SAVE LAST MESSAGE CALL")
        
        JaniTime.userDefaults.set(message, forKey: "message")
        JaniTime.userDefaults.synchronize()
        
        self.getLastMessage()
    }
    
    // Just for testing purposes.
    func getLastMessage(){
        if let lastmessage = JaniTime.userDefaults.string(forKey: "message"){
            // This works, it saves and get's the appropriate value.
            print("Last Message Was \(lastmessage)")
            
            // TODO: check the last message with the last one the api returns to us and if they're the same then don't do anything. Else, redirect user to MessageViewController.
        } else {
            print("Could not get last message")
        }
    }
    
}
