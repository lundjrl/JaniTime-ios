//
//  General.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 07/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class JaniTime {
    static let parsingData = ParsingData()
    static let userDefaults = UserDefaults.standard
    static let user = User()
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func setBackGroundGradient(color: [CGColor] = [UIColor(red: 94.0/255.0, green: 95.0/255.0, blue: 253.0/255.0, alpha: 1.0).cgColor,
                                                   UIColor(red: 83.0/255.0, green: 87.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor,
                                                   UIColor(red: 58.0/255.0, green: 64.0/255.0, blue: 188.0/255.0, alpha: 1.0).cgColor,
                                                   UIColor(red: 42.0/255.0, green: 49.0/255.0, blue: 149.0/255.0, alpha: 1.0).cgColor,
                                                   UIColor(red: 33.0/255.0, green: 40.0/255.0, blue: 128.0/255.0, alpha: 1.0).cgColor], view: UIView)  {
        view.setGradientWith(colors: color)
        
        

    }
    
    enum animationLoaderType {
        case loading
    }
    
    static let lottieFiles: [animationLoaderType: String] = [
        .loading: "loader"]
    
    // Time ago label
    func timeAgoSinceDate(date: NSDate, numericDates: Bool) -> (Int?, Int?, Int?, String?) {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date, to: latest as Date)
        let hourValue = components.hour
        let minuteValue = components.minute
        let secondsValue = components.second
        if (components.year! >= 2) {
            return (hourValue, minuteValue, secondsValue, "\(components.year!) years ago")
        } else if (components.year! >= 1) {
            if (numericDates) {
                return (hourValue, minuteValue, secondsValue, "1 year ago")
            } else {
                return (hourValue, minuteValue, secondsValue, "Last year")
            }
        } else if (components.month! >= 2) {
            return (hourValue, minuteValue, secondsValue, "\(components.month!) months ago")
        } else if (components.month! >= 1) {
            if (numericDates) {
                return (hourValue, minuteValue, secondsValue, "1 month ago")
            } else {
                return (hourValue, minuteValue, secondsValue, "Last month")
            }
        } else if (components.weekOfYear! >= 2) {
            return (hourValue, minuteValue, secondsValue, "\(components.weekOfYear!) weeks ago")
        } else if (components.weekOfYear! >= 1) {
            if (numericDates) {
                return (hourValue, minuteValue, secondsValue, "1 week ago")
            } else {
                return (hourValue, minuteValue, secondsValue, "Last week")
            }
        } else if (components.day! >= 2) {
            return (hourValue, minuteValue, secondsValue, "\(components.day!) days ago")
        } else if (components.day! >= 1) {
            if (numericDates) {
                return(hourValue, minuteValue, secondsValue,  "1 day ago")
            } else {
                return (hourValue, minuteValue, secondsValue, "Yesterday")
            }
        } else if (components.hour! >= 2) {
            return (hourValue, minuteValue, secondsValue, "\(components.hour!) hours ago")
        } else if (components.hour! >= 1) {
            if (numericDates) {
                return (hourValue, minuteValue, secondsValue, "1 hour ago")
            } else {
                return (hourValue, minuteValue, secondsValue, "An hour ago")
            }
        } else if (components.minute! >= 2) {
            return (hourValue, minuteValue, secondsValue, "\(components.minute!) mins ago")
        } else if (components.minute! >= 1) {
            if (numericDates) {
                return (hourValue, minuteValue, secondsValue, "1 min ago")
            } else {
                return (hourValue, minuteValue, secondsValue, "A min ago")
            }
        } else {
            return (hourValue, minuteValue, secondsValue, "Just now")
        }
        //        else if (components.second! >= 3) {
        //            return "\(components.second!) seconds ago"
        //        }
    }
    
    static func vibrateDevice(times: Int) {
        for i in 1...times {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.3 * Double(i)), execute: {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            })
        }
    }
    
}
class Logger {
    static func print(_ items: Any...) {
        let separator = " "
        let terminator = "\n"
        var output = items.map { "*\($0)" }.joined(separator: separator)
        #if DEBUG
        output = items.map { "*\($0)" }.joined(separator: separator)
        #else
        output = " "
        output = items.map { "*\($0)" }.joined(separator: separator)
        #endif
        Swift.print(output, terminator: terminator)
    }
}


public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
