//
//  CheckInCell.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 07/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit

class CheckInCell: UITableViewCell {
    @IBOutlet weak var checkInTitle: UILabel!
    
    @IBOutlet weak var checkInTimeDisplay: UILabel!
    
    @IBOutlet weak var dayDateLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        infoView.makeCapsuleShape(color: .clear)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
