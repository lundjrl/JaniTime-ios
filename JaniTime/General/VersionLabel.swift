//
//  VersionLabel.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 27/04/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import Foundation
import UIKit

class VersionLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setVersionLabel()
    }
    
    func setVersionLabel() {
        super.textAlignment = .center
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            super.text = appVersion
        } else {
            super.text = ""
        }
    }
    
}
