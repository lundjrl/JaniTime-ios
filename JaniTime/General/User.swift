//
//  User.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 13/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import Foundation
import UIKit

class User {
    var client_id: String {
        get {
            if let _client_id = JaniTime.userDefaults.value(forKey: Constants.Keys.CLIENT_ID) as? String {
                return _client_id
            }
            return ""
        }
        set {
            JaniTime.userDefaults.set(newValue, forKey: Constants.Keys.CLIENT_ID)
        }
    }
    
    var client_company: String {
        get {
            if let _client_company = JaniTime.userDefaults.value(forKey: Constants.Keys.CLIENT_COMPANY)  as? String {
                return _client_company
            }
            return ""
        }
        set {
            JaniTime.userDefaults.set(newValue, forKey: Constants.Keys.CLIENT_COMPANY)
        }
    }
    
    var user_id: String {
        get {
            if let _user_id = JaniTime.userDefaults.value(forKey: Constants.Keys.USER_ID)  as? String {
                return _user_id
            }
            return ""
        }
        set {
            JaniTime.userDefaults.set(newValue, forKey: Constants.Keys.USER_ID)
        }
    }
    
    var building_id: String {
        get {
            if let _building_id = JaniTime.userDefaults.value(forKey: Constants.Keys.BUILDING_ID)  as? String {
                return _building_id
            }
            return ""
        }
        set {
            JaniTime.userDefaults.set(newValue, forKey: Constants.Keys.BUILDING_ID)
        }
    }
    
    var user_type: String {
        get {
            if let _user_type = JaniTime.userDefaults.value(forKey: Constants.Keys.USER_TYPE)  as? String {
                return _user_type
            }
            return ""
        }
        set {
            JaniTime.userDefaults.set(newValue, forKey: Constants.Keys.USER_TYPE)
        }
    }
    
    
    var hasAutoClockedOut: Bool = false
    
    var isTimerRunning: Bool = false
    
    var employeeAutoClockOut: Bool = false
    var employeeTracking:Bool = false
    var trackingInterval: Int? = 0
    var intervalDisplay = ""
}
