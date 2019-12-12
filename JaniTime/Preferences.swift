//
//  Preferences.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 08/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class Preferences: Object {
    @objc dynamic var building = ""
    @objc dynamic var userId = ""
    @objc dynamic var buildingId = ""
    @objc dynamic var userType = ""
    @objc dynamic var managerCode = 0
    @objc dynamic var managerType = ""
    @objc dynamic var date = Date()
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
}

struct clockInData {
    var client_id = 0
    var building_id = 0
    var employee_id = 0
    var manager_code = 0
    var manager_name = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var user_type = ""
    var name = ""
    var action = ""
}
