//
//  CheckInMapCell.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 08/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit
import GoogleMaps

class CheckInMapCell: UITableViewCell {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.mapType = .satellite
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
