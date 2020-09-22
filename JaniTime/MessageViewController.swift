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
                
        let messageNib = UINib(nibName: "MessageCell", bundle: nil)
        
        messagesTable.register(messageNib, forCellReuseIdentifier: "MessageCell")
        
        // Init table UI features
        messagesTable.allowsSelection = false // ?
        messagesTable.separatorStyle = .none
        messagesTable.bounces = false
        
        getEmployerMessages()
        
    }
    
    // Do something when onFocus listener fires off
    @objc func appMovedToForeground(){
        print("App is in Foreground")
        
    }
    
    // Causing messages to get duplicated in array
//    @objc override func viewDidAppear(_ animated: Bool) {
//        print("View reappeared")
//        getEmployerMessages()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return JaniTime.parsingData.messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let messageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell {
            let currentMessage = JaniTime.parsingData.messages[indexPath.row]
            
            let now = TimeInterval(currentMessage.date_posted)
            let date = Date(timeIntervalSince1970: now)
            let fullFormatter = DateFormatter()
            fullFormatter.dateStyle = .full
            let time = fullFormatter.string(from: date)

            messageCell.messageTitle.text = currentMessage.title
            messageCell.messageDate.text = time
            messageCell.messageBody.text = currentMessage.body
            
            messageCell.layer.borderWidth = 2
            
            print("DATE: \(messageCell.messageDate.text)")
            print("POSTED DATE: \(currentMessage.date_posted)")

            return messageCell

        } else {
            return UITableViewCell()
        }
    }
    
    // Call to get message data from API
    func getEmployerMessages() {
        let params: [String : Int] = ["user_id": Int(JaniTime.user.user_id) ?? 0, "client_id": Int(JaniTime.user.client_id)! ]
        api.callAPI(params: params, APItype: .messages, APIMethod: .post) { (message, status) in
            if status {
                print("CAlled API HEY")
                self.saveLastMessage(message: message)
                DispatchQueue.main.async {
                    self.messagesTable.reloadData()
                }
            } else {
                self.saveLastMessage(message: "FAILED")
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
        JaniTime.userDefaults.set(message, forKey: "message")
        JaniTime.userDefaults.set(message, forKey: "lastsavedmessage")
        JaniTime.userDefaults.synchronize()
    }
}
