//
//  MessageCell.swift
//  JaniTime
//
//  Created by James Lund on 9/16/20.
//  Copyright © 2020 Sidharth J Dev. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageTitle: UILabel!
    
    @IBOutlet weak var messageBody: UILabel!
    
    @IBOutlet weak var messageDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("Awakening from Nib")
    }
    
//    Show more here for when user presses on message
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print("Set Selected")
    }
}
