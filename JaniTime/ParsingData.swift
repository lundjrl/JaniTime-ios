//
//  ParsingData.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 12/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import CoreLocation

class ParsingData {
    
    var punchingHistory: [PunchingHistoryTemplate] = []
    var messages: [MessagesTemplate] = []
    var companyList: [CompanyTemplate] = []
    var clockInData: ClockInTemplate? = nil
    class PunchingHistoryTemplate {
    
        var clock_time_in = Double()
        var clock_time_out = Double()
        var clock_duration = Double()
        var buidingName = ""
        var building_latitude = Double()
        var building_longitude = Double()
        var forcedClockout = false
        
        init(json: [String : AnyObject]) {
            if let _clock_time_in = json["clock_time_in"] as? Double {
                self.clock_time_in = _clock_time_in
            }
            if let _clock_time_out = json["clock_time_out"] as? Double {
                self.clock_time_out = _clock_time_out
            }
            if let _clock_duration = json["clock_duration"] as? Double {
                self.clock_duration = _clock_duration
            }
            if let _buidingName = json["building_name"] as? String {
                self.buidingName = _buidingName
            }
            if let _building_latitude = json["building_latitude"] as? Double {
                self.building_latitude = _building_latitude
            }
            if let _building_longitude = json["building_longitude"] as? Double {
                self.building_longitude = _building_longitude
            }
            if let _isForcedClockOut = json["is_forced_clock_out"] as? Bool {
                self.forcedClockout = _isForcedClockOut
            }
        }
        
//        "clock_time_in": 1551758641,
//        "clock_time_out": 1551767359,
//        "clock_duration": 8718,
//        "building_name": "PFCU Portland 1st",
//        "building_latitude": 42.856434,
//        "building_longitude": -84.89042
        
    }
    
    class CompanyTemplate {
        var client_id = ""
        var client_company = ""
        
        init(json: [String : AnyObject]) {
            if let _client_id = json["client_id"] as? String {
                self.client_id = _client_id
            }
            if let _client_company = json["cli_company"] as? String {
                self.client_company = _client_company
            }
        }
    }
    
    class ClockInTemplate {
        var building_name = ""
        var clock_time_in: Double = 0.0
        
        var building_location: CLLocation? = nil
        var building_radius: Double = 0.0
        
        init(json: [String : AnyObject]) {
            Logger.print(json)
            if let _building_name = json["building_name"] as? String {
                self.building_name = _building_name
            }
            if let _clock_time_in = json["clock_time_in"] as? Double {
                self.clock_time_in = _clock_time_in
            }
        
            if let _building_radius = json["building_radius"] as? Double {
                self.building_radius = _building_radius
            }
            if let _building_latitude = json["building_latitude"] as? Double {
                if let _building_longitude = json["building_longitude"] as? Double {
                    self.building_location = CLLocation(latitude: _building_latitude, longitude: _building_longitude)
                }
            }
        }
       
    }
    
    class MessagesTemplate {
        var title = ""
        var body = ""
        var date_posted = 0
        var client_id = 0
        var user_posted = ""
        
        init(json: [String : AnyObject]) {
            Logger.print(json)
            if let _title = json["message_title"] as? String {
                self.title = _title
            }
            if let _body = json["message"] as? String {
                self.body = _body
            }
            if let _date = json["date_posted"] as? Int {
                self.date_posted = _date
            }
            if let _id = json["client_id"] as? Int {
                self.client_id = _id
            }
            if let _user_posted = json["user_posted"] as? String {
                self.user_posted = _user_posted
            }
        }
    }
}
