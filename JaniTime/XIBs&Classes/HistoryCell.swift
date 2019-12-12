//
//  HistoryCell.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 07/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit
import MarqueeLabel

class HistoryCell: UITableViewCell {

    @IBOutlet weak var buildingName: MarqueeLabel!
    
    @IBOutlet weak var dayDateTimeLabel: MarqueeLabel!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var forcedClockOutLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        forcedClockOutLabel.makeCapsuleShape(color: .clear)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
