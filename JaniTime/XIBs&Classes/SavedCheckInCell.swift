//
//  SavedCheckInCell.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 08/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit
import MarqueeLabel

class SavedCheckInCell: UITableViewCell {

    @IBOutlet weak var buildingName: MarqueeLabel!
    
    @IBOutlet weak var userBuildingId: MarqueeLabel!
    
    @IBOutlet weak var userType: MarqueeLabel!
    
    @IBOutlet weak var dateLabel: MarqueeLabel!
    
    @IBOutlet weak var timeLabel: MarqueeLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
