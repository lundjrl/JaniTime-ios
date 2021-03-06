//
//  API.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 07/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import UIKit
import CoreLocation


class API {
    #if DEBUG
    public let baseUrl = Constants.urls.developmentServerUrl
    #else
    public let baseUrl = Constants.urls.productionServerUrl
    //    public let baseUrl = Constants.urls.developmentServerUrl
    #endif
    
    
    private let punchingHistory = "/punching_history/list.php"
    private let clock_in_out = "/clock/update.php"
    private let clock_current = "/clock/list.php"
    private let company_list = "/company/list.php"
    private let validate_employee = "/company/check_employee_code.php"
    private let messages = "/message_history/list.php"
    
    enum type {
        case punchingHistory
        case clock_in_out
        case clock_current
        case company_list
        case validate_employee
        case messages
    }
    
    func getAPIUrl(APItype: type) -> String {
        var apiUrl = baseUrl
        
        switch APItype {
        case .punchingHistory:
            apiUrl.append(punchingHistory)
        case .clock_in_out:
            apiUrl.append(clock_in_out)
        case .clock_current:
            apiUrl.append(clock_current)
        case .company_list:
            apiUrl.append(company_list)
        case .validate_employee:
            apiUrl.append(validate_employee)
        case .messages:
            apiUrl.append(messages)
        }
        
        return apiUrl
    }
    
    private var sessionManager: SessionManager?
    
    func alamofireCall(url: String, params: Parameters?, headers: HTTPHeaders, APIMethod: HTTPMethod, urlEncoding: Bool, CompletionHandler: @escaping ((DataResponse<Any>), Bool) -> ()) {
        
        Alamofire.request(url, method: APIMethod, parameters: params, encoding: (urlEncoding ? URLEncoding.default : JSONEncoding.default), headers: headers).responseJSON
            { response in
                Logger.print(response)
                print("response above")
                //IF SESSION EXPIRED, LOGOUT THE USER
                
                if response.response?.statusCode != nil {
                    if "\(response.response!.statusCode)" == Constants.StatusCodes.session_expired {
                        
                        CompletionHandler(response, false)
                        return
                    }  else if "\(response.response!.statusCode)" == Constants.StatusCodes.force_update {
                        CompletionHandler(response, false)
                        return
                    }
                }
                CompletionHandler(response, true)
        }
    }
    
    func callAPI(params: Parameters, urlParameters: String = "", APItype: type, APIMethod: HTTPMethod, withUrlEncoding: Bool = false, shouldPresentPendingScreen: Bool = true, CompletionHandler: @escaping (String, Bool) -> ()) {
        var apiParameters: Parameters? = params
        
        if APIMethod == .get {
            apiParameters = nil
        }
        
        var apiUrl = getAPIUrl(APItype: APItype)
        
        apiUrl.append(urlParameters)
        
        var app_version = "1.0.4"
        if getAppVersion() != "" {
            app_version = getAppVersion()
        }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "OS" : "ios",
            "App-Version" : app_version,
            "Device" : UIDevice.modelName
        ]
        
        
        Logger.print("\nURL:\(apiUrl)\nPARAMS: \(params)\nHEADERS: \(headers)\n METHOD: \(APIMethod)\n")
        
        if withUrlEncoding {
            Logger.print("Encoded")
        }
        
        alamofireCall(url: apiUrl, params: apiParameters, headers: headers, APIMethod: APIMethod, urlEncoding: withUrlEncoding) { (response, status) in
            
            print("ALAMO RESPONSE")
            print("API params: \(String(describing: apiParameters))")
            
            
            switch response.result {
            case .success:
                
                if let json = response.result.value as? [String: AnyObject] {
                    if let data = json["data"] {
                        
                        var message = Constants.Messages.INCOMPLETE_DATA_FROM_SERVER
                        if let val = data[Constants.Keys.MESSAGE] as? String {
                            message = val
                        }
                        switch APItype {
                            
                        case .punchingHistory:
                            if let status = json[Constants.Keys.STATUS]?.stringValue {
                                if status == Constants.StatusCodes.success {
                                    CompletionHandler(message, true)
                                    
                                    if let historyData = data["history"] as? [[String : AnyObject]] {
                                        JaniTime.parsingData.punchingHistory.removeAll()
                                        for each in historyData {
                                            JaniTime.parsingData.punchingHistory.append(ParsingData.PunchingHistoryTemplate(json: each))
                                        }
                                        
                                    }
                                    Logger.print(data)
                                    return
                                } else {
                                    CompletionHandler(message, false)
                                    return
                                }
                            }
                        case .clock_in_out:
                            if let status = json[Constants.Keys.STATUS]?.stringValue {
                                if status == Constants.StatusCodes.success {
                                    if let data = json["data"] as? [String : AnyObject] {
                                        JaniTime.parsingData.clockInData = ParsingData.ClockInTemplate(json: data)
                                        
                                    }
                                    CompletionHandler(message, true)
                                    return
                                } else {
                                    CompletionHandler(message, false)
                                    return
                                }
                            }
                        case .clock_current:
                            if let status = json[Constants.Keys.STATUS]?.stringValue {
                                
                                if let _data = json["data"] as? [String : AnyObject] {
                                    if let _employee_auto_clock = _data["employee_auto_clock"] as? Bool {
                                        JaniTime.user.employeeAutoClockOut = _employee_auto_clock
                                        //                                        JaniTime.user.employeeAutoClockOut = false
                                    }
                                    if let _employee_tracking = _data["employee_tracking"] as? Bool {
                                        JaniTime.user.employeeTracking = _employee_tracking
                                        //                                        JaniTime.user.employeeTracking = false
                                    }
                                    if let _tracking_interval = _data["tracking_interval"] as? String {
                                        JaniTime.user.trackingInterval = Int(_tracking_interval)
                                        if JaniTime.user.trackingInterval != nil {
                                            JaniTime.user.intervalDisplay = JaniTime.user.trackingInterval!.toTime()
                                        }
                                    }
                                    
                                }
                                if status == Constants.StatusCodes.success {
                                    if let data = json["data"] as? [String : AnyObject] {
                                        JaniTime.parsingData.clockInData = ParsingData.ClockInTemplate(json: data)
                                    }
                                    CompletionHandler(message, true)
                                    return
                                } else if status == Constants.StatusCodes.clocked_out {
                                    JaniTime.user.hasAutoClockedOut = true
                                    CompletionHandler("clocked-out", true)
                                    return
                                } else if JaniTime.user.isTimerRunning && status == Constants.StatusCodes.error_invalid_mobile {
                                    JaniTime.user.hasAutoClockedOut = true
                                    CompletionHandler("clocked-out", true)
                                    return
                                } else {
                                    CompletionHandler(message, false)
                                    return
                                }
                            }
                        case .company_list:
                            if let status = json[Constants.Keys.STATUS]?.stringValue {
                                if status == Constants.StatusCodes.success {
                                    Logger.print(data)
                                    
                                    if let countryData = data["company"] as? [[String : AnyObject]] {
                                        JaniTime.parsingData.companyList.removeAll()
                                        for each in countryData {
                                            JaniTime.parsingData.companyList.append(ParsingData.CompanyTemplate(json: each))
                                            
                                        }
                                    }
                                    CompletionHandler(message, true)
                                    return
                                } else {
                                    CompletionHandler(message, false)
                                    return
                                }
                            }
                            
                        case .validate_employee:
                            if let status = json[Constants.Keys.STATUS]?.stringValue {
                                if status == Constants.StatusCodes.success {
                                    Logger.print(data)
                                    
                                    if let companyName = data["company_name"] as? String {
                                        Logger.print(companyName)
                                        JaniTime.user.client_company = companyName
                                    }
                                    CompletionHandler(message, true)
                                    return
                                } else {
                                    CompletionHandler(message, false)
                                    return
                                }
                            }
                        case .messages:
                            if let status = json[Constants.Keys.STATUS]?.stringValue {
                                if status == Constants.StatusCodes.success {
                                    if let data = json["data"] as? [String : AnyObject] {
                                        if let messageData = data["message"] as? [[String : AnyObject]] {
                                            JaniTime.parsingData.messages.removeAll()
                                            for each in messageData.reversed() {
                                                JaniTime.parsingData.messages.append( ParsingData.MessagesTemplate(json: each))
                                                                                                
                                            }
                                            
                                            message = JaniTime.parsingData.messages.first?.body as! String
                                        }
                                        
                                    }
                                    CompletionHandler(message, true)
                                    return
                                } else {
                                    CompletionHandler(message, false)
                                    return
                                }
                            }
                        }
                        //end of switch
                    } else {
                        CompletionHandler(Constants.Messages.UNKNOWN_ERROR_OCCURED, false)
                    }
                    
                    
                }
                
                break
                
            case .failure(let error):
                var errorMessage = error.localizedDescription
                Logger.print("====ERROR====\(params)")
                if response.response?.statusCode != nil {
                    errorMessage = ""
                }
                CompletionHandler(errorMessage, false)
                break
            }
        }
    }
    
    
    func stopAllRequests() {
        Alamofire.SessionManager.default.session.invalidateAndCancel()
    }
    private func getAppVersion() -> String {
        if Bundle.main.infoDictionary != nil {
            return "\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
        }
        return ""
    }
}
