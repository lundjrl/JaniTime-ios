//
//  CheckedInFullMapCell.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 22/05/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit
import GoogleMaps

class CheckedInFullMapCell: UITableViewCell {

    @IBOutlet weak var fullMapView: GMSMapView!
    override func awakeFromNib() {
        super.awakeFromNib()
        fullMapView.mapType = .satellite
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
