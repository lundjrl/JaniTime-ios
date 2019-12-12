//
//  ViewController.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 07/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import RealmSwift
import Toast_Swift
import UICircularProgressRing

var currentLocation: CLLocation? = nil


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataEntryDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var homeTable: UITableView!
    
    var isTimerRunning = false
    var checkedInTime = Date()
    
    @IBOutlet weak var checkInButton: UIButton!
    
    
    @IBOutlet weak var saveButton: UIButton!
    struct checkInCheckOutImage {
        static let checkInButtonImage = UIImage(named: "checkin_button")
        static let checkOutButtonImage = UIImage(named: "checkout_button")
        static let forcedCheckOutButtonImage = UIImage(named: "checkout_forced_button")
    }
    
    struct mapMarker {
        static let markerImage = UIImage(named: "map_marker")
    }
    
    
    let api = API()
    
    var getSavedCheckIn = true
    
    var clockedinData: clockInData? = nil
    
    var locationManager = CLLocationManager()
    
    var goToSaved = false
    var animationSize: CGFloat = 0.1
//
    var gotCurrentStatus = false
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var clearButton: UIButton!
    
    var dispatchedLocalNotification = false
    var dispatchedWarningNotification = false
    
    let changingLocation = CLLocation(latitude: 53.058395, longitude: 70.023578)
    
    var switchingCount = 0
    
    @IBOutlet weak var progressRing: UICircularProgressRing!
    
    @IBOutlet weak var warningBanner: UIView!
    
    var isUpdatingLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let checkInNib = UINib(nibName: "CheckInCell", bundle: nil)
        let historyNib = UINib(nibName: "HistoryCell", bundle: nil)
        let checkInMapNib = UINib(nibName: "CheckInMapCell", bundle: nil)
        let checkedInFullMapNib = UINib(nibName: "CheckedInFullMapCell", bundle: nil)
        let batterySaverNib = UINib(nibName: "BatterySaverCell", bundle: nil)
        
        homeTable.register(checkInNib, forCellReuseIdentifier: "CheckInCell")
        homeTable.register(historyNib, forCellReuseIdentifier: "HistoryCell")
        homeTable.register(checkInMapNib, forCellReuseIdentifier: "CheckInMapCell")
        homeTable.register(checkedInFullMapNib, forCellReuseIdentifier: "CheckedInFullMapCell")
        homeTable.register(batterySaverNib, forCellReuseIdentifier: "BatterySaverCell")
        setCheckInCheckOutButton()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
//        getCompanyList()

        getPunchingHistory()
        
        saveButton.isHidden = true
        
        homeTable.allowsSelection = false
        homeTable.separatorStyle = .none
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAct(_:)))
        checkInButton.addGestureRecognizer(longGesture)
        progressRing.isHidden = true
        
        warningBanner.makeCapsuleShape(color: .clear)
        homeTable.bounces = false
//        homeTable.estimatedRowHeight = 175.0
//        homeTable.rowHeight = UITableView.automaticDimension
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if JaniTime.user.client_company != "" {
            titleLabel.text = JaniTime.user.client_company
        } else {
            titleLabel.text = "Home"
        }
        dispatchedWarningNotification = false
    }
    
    func getCompanyList() {
        api.callAPI(params: [:], APItype: .company_list, APIMethod: .get) { (message, status) in
            self.view.hideLoaderAnimation()
            if status {
                if JaniTime.user.client_id == "" {
                    self.getSavedCheckIn = false
                    self.goToSavedCheckIn()
                }
            }
        }
    }
    
    @objc func statusCheck() {
        if shouldUpdateLocation && currentLocation != nil {
            getCurrentStatus(withAnimation: false)
        } else if currentLocation == nil {
            showLocationWarning()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if isTimerRunning {
                return 1
            }
            return JaniTime.parsingData.punchingHistory.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: homeTable.frame.size.width, height: 0))
            headerView.backgroundColor = .clear
            return headerView
        } else if !isTimerRunning{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: homeTable.frame.size.width, height: 40))
            headerView.backgroundColor = .white
            let headerTitle = UILabel(frame: CGRect(x: 16, y: 0, width: homeTable.frame.size.width, height: 40))
            headerTitle.font = UIFont(name: "SFUIDisplay-Bold", size: 21.0)
            headerTitle.text = "History"
            headerTitle.textColor = UIColor(hex: "0882d8")
            headerView.addSubview(headerTitle)
            return headerView
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            if isTimerRunning {
                return 0
            }
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00000
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if !isTimerRunning {
                if let checkInMapCell = tableView.dequeueReusableCell(withIdentifier: "CheckInMapCell") as? CheckInMapCell {
                    if currentLocation != nil {
                        let camera = GMSCameraPosition(target: currentLocation!.coordinate, zoom: 12)
                        let marker = GMSMarker()
                        checkInMapCell.mapView.clear()
                        marker.map = nil
                        marker.position = currentLocation!.coordinate
                        marker.map = checkInMapCell.mapView
                        marker.icon = mapMarker.markerImage
                        checkInMapCell.mapView.animate(to: camera)
                        checkInMapCell.mapView.isMyLocationEnabled = true
                        checkInMapCell.mapView.settings.myLocationButton = true
                    }
                    
                    do {
                        if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
                            checkInMapCell.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                        } else {
                            NSLog("Unable to find map_style.json")
                        }
                    } catch {
                        NSLog("One or more of the map styles failed to load. \(error)")
                    }
                    
                    
                    return checkInMapCell
                }
                return UITableViewCell()
            }
            else {
                if let checkInCell = tableView.dequeueReusableCell(withIdentifier: "CheckInCell") as? CheckInCell {
                    if isTimerRunning {
                        DispatchQueue.global(qos: .background).async {
                            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.getTime), userInfo: nil, repeats: true)
                        }
                        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getTime), userInfo: nil, repeats: true)
                    }
                    let today = Date()
                    let fullFormatter = DateFormatter()
                    fullFormatter.dateFormat = "EEEE, dd-MM-yyyy"
                    let todayString = fullFormatter.string(from: today)
                    checkInCell.infoView.isHidden = false
                    if JaniTime.user.employeeAutoClockOut {
                        checkInCell.infoLabel.text = "Auto clockout ON"
                    } else if JaniTime.user.employeeTracking {
                        checkInCell.infoLabel.text = "Tracking ON"
                        if JaniTime.user.trackingInterval != nil, JaniTime.user.trackingInterval! > 0 {
                            if JaniTime.user.intervalDisplay != "" {
                                checkInCell.infoLabel.text = "Tracking every (\(JaniTime.user.intervalDisplay))"
                            } else {
                                checkInCell.infoLabel.text = "Tracking every (\(JaniTime.user.trackingInterval)!s)"
                            }
                            
                        }
                    } else {
                        checkInCell.infoView.isHidden = true
                    }
                    checkInCell.dayDateLabel.text = todayString
//                    checkInCell.infoLabel.text =
                    if JaniTime.parsingData.clockInData != nil {
                        checkInCell.locationLabel.text = JaniTime.parsingData.clockInData!.building_name
                    } else {
                        checkInCell.locationLabel.text = ""
                    }
                    
                    return checkInCell
                }
            }
            return UITableViewCell()
        } else if isTimerRunning {
            if !JaniTime.user.employeeTracking && !JaniTime.user.employeeAutoClockOut {
                if let fullBatteryCell = tableView.dequeueReusableCell(withIdentifier: "BatterySaverCell") as? BatterySaverCell {
                    return fullBatteryCell
                }
            } else if let fullMapCell = tableView.dequeueReusableCell(withIdentifier: "CheckedInFullMapCell") as? CheckedInFullMapCell {
                if currentLocation != nil {
                    let camera = GMSCameraPosition(target: currentLocation!.coordinate, zoom: 20)
                    let marker = GMSMarker()
                    fullMapCell.fullMapView.clear()
                    marker.map = nil
                    fullMapCell.fullMapView.animate(to: camera)
                    fullMapCell.fullMapView.isMyLocationEnabled = true
                    fullMapCell.fullMapView.settings.myLocationButton = true
                    if JaniTime.parsingData.clockInData != nil, JaniTime.parsingData.clockInData!.building_location != nil {
                        let circleCenter = JaniTime.parsingData.clockInData!.building_location!
                        let circ = GMSCircle(position: circleCenter.coordinate, radius: JaniTime.parsingData.clockInData!.building_radius)
                        circ.fillColor = UIColor(hex: "0882d8").withAlphaComponent(0.2)
                        circ.strokeColor = UIColor(hex: "0882d8").withAlphaComponent(0.8)
                        circ.strokeWidth = 2
                        circ.map = fullMapCell.fullMapView
                        
                        marker.position = JaniTime.parsingData.clockInData!.building_location!.coordinate
                        marker.map = fullMapCell.fullMapView
                        marker.icon = mapMarker.markerImage
                    }
                }
                do {
                    if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
                        fullMapCell.fullMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                    } else {
                        NSLog("Unable to find map_style.json")
                    }
                } catch {
                    NSLog("One or more of the map styles failed to load. \(error)")
                }
                return fullMapCell
            }
            return UITableViewCell()
        } else {
            if let historyCell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryCell {
                let currentHistory = JaniTime.parsingData.punchingHistory[indexPath.row]
                historyCell.buildingName.text = currentHistory.buidingName
                historyCell.forcedClockOutLabel.isHidden = !currentHistory.forcedClockout
                let fullFormatter = DateFormatter()
                fullFormatter.dateFormat = "EEEE, dd-MM-yyyy. hh:mm a"
                let outFormatter = DateFormatter()
                outFormatter.dateFormat = "hh:mm a"
                let inTime = Date(timeIntervalSince1970: currentHistory.clock_time_in)
                let outTime = Date(timeIntervalSince1970: currentHistory.clock_time_out)
                
                let outString = outFormatter.string(from: outTime)
                let inString = fullFormatter.string(from: inTime)
                historyCell.dayDateTimeLabel.text = "\(inString)-\(outString)"
                
                let cal = Calendar.current
                
                let components = cal.dateComponents([.hour, .minute, .second], from: inTime, to: outTime)
                
                let totalString = String(format: "%02d:%02d:%02d", components.hour ?? 00, components.minute ?? 00, components.second ?? 00)
                historyCell.totalTimeLabel.text = totalString
                if currentHistory.forcedClockout {
                    historyCell.totalTimeLabel.text = "--:--:--"
                }
                return historyCell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 185.0
        } else {
            if isTimerRunning {
                if !JaniTime.user.employeeTracking && !JaniTime.user.employeeAutoClockOut {
                    return 320
                }
                return self.view.frame.size.height - (185.0 + 80)
            }
            
            return 100.0
        }
    }
    var changedLocation = false
    
    var shouldUpdateLocation = true
    
    var lastUpdatedTime: Date? = nil
    
    @objc func getTime() {
        if let timerCell = homeTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? CheckInCell {
            let (hours, minutes, seconds, value) = JaniTime().timeAgoSinceDate(date: checkedInTime as NSDate, numericDates: false)
            Logger.print(value ?? "")
            if isTimerRunning {
                timerCell.checkInTimeDisplay.text = String(format: "%02d:%02d:%02d", hours ?? 00, minutes ?? 00, seconds ?? 00)
                if currentLocation != nil && shouldUpdateLocation {
                    if lastUpdatedTime == nil {
                        updateLocation()
                        lastUpdatedTime = Date()
                    } else {
                        let (_, _, _seconds, _) = JaniTime().timeAgoSinceDate(date: lastUpdatedTime! as NSDate, numericDates: false)
                        if _seconds != nil, _seconds! > 7 {
                            updateLocation()
                            lastUpdatedTime = Date()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func checkInCheckOutAct(_ sender: Any) {
        if !isTimerRunning {
            if currentLocation != nil {
                goToCheckIn()
            } else {
                showLocationWarning()
            }
            
        } else {
            let _isUserInGeoFence = isUserInGeoFence().0 ?? true
            let title = _isUserInGeoFence ? "Confirm Clock-Out" : "Forgot to clock out?"
            let message = _isUserInGeoFence ? "Are you sure you want to clock-out?" : "Your clock out time will be flagged, please talk with the manager"
            let clockoutAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                if currentLocation != nil {
                    if !_isUserInGeoFence {
                       self.dispatchedWarningNotification = true
                    }
                    self.clockOut(isForced: !_isUserInGeoFence)
                }
            }
            let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
                
            }
            clockoutAlert.addAction(yesAction)
            clockoutAlert.addAction(noAction)
            self.present(clockoutAlert, animated: true, completion: nil)
        }
    }
    
    func setCheckInCheckOutButton() {
        if isTimerRunning {
            let _isUserInGeoFence = isUserInGeoFence().0 ?? true
            checkInButton.setImage((_isUserInGeoFence) ? checkInCheckOutImage.checkOutButtonImage : checkInCheckOutImage.forcedCheckOutButtonImage, for: .normal)
            warningBanner.isHidden = _isUserInGeoFence
        } else {
            checkInButton.setImage(checkInCheckOutImage.checkInButtonImage, for: .normal)
            warningBanner.isHidden = true
        }
    }
    
    func handleTimer(timerStart: Bool = false, time: Date = Date()) {
        isTimerRunning = timerStart
        JaniTime.user.isTimerRunning = isTimerRunning
        if isTimerRunning {
            saveButton.isHidden = true
            clearButton.isHidden = true
            self.scrollToFirstRow()
            checkedInTime = time
            if !JaniTime.user.employeeTracking && !JaniTime.user.employeeAutoClockOut {
                locationManager.stopUpdatingLocation()
                isUpdatingLocation = false
            } else {
                locationManager.startUpdatingLocation()
            }
        } else {
            saveButton.isHidden = false
            clearButton.isHidden = false
        }
        saveButton.isHidden = true
        DispatchQueue.main.async {
//            self.homeTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.homeTable.reloadData()
        }
        
        setCheckInCheckOutButton()
    }
    
    func goToCheckIn() {
//        let displayMessage = "Something went wrong. Please check your network and try again later."
//
//        self.showAlert(message: displayMessage, title: "Oops")
        performSegue(withIdentifier: Constants.Segue.HOME_CHECKIN, sender: self)
    }
    
    func goToSavedCheckIn() {
//        let displayMessage = "Something went wrong. Please check your network and try again later."
//
//        self.showAlert(message: displayMessage, title: "Oops")
        performSegue(withIdentifier: Constants.Segue.HOME_SAVED, sender: self)
    }
    
    func dataEntered(data: clockInData, savingData: Preferences?) {
    
        let params: [String : Any] = ["client_id":Int(JaniTime.user.client_id) ?? 0, "building_id": data.building_id, "employee_id": data.employee_id, "manager_code": data.manager_code, "latitude": data.latitude, "longitude": data.longitude, "user_type": data.user_type, "name":data.name, "action" : "clock-in"]
        JaniTime.user.building_id = "\(data.building_id)"
        JaniTime.user.user_id = "\(data.employee_id)"
        JaniTime.user.user_type = data.user_type
        Logger.print(params)
        self.view.showLoaderAnimation(loaderType: .loading, message: "Clocking In", animationViewSizeMultiplier: animationSize)
        api.callAPI(params: params, APItype: .clock_in_out, APIMethod: .post) { (message, status) in
            self.view.hideLoaderAnimation()
            self.shouldUpdateLocation = true
            if status {
                self.clockedinData = data
                self.handleTimer(timerStart: true)
                self.dispatchedLocalNotification = false
                self.showAlert(message: "You are clocked-in", title: "Success")
                JaniTime.user.hasAutoClockedOut = false
                let _isUserInGeoFence = self.isUserInGeoFence()
                if _isUserInGeoFence.0 != nil, !_isUserInGeoFence.0! {
//                    self.progressRing.isHidden = false
                    self.checkInButton.setImage(checkInCheckOutImage.forcedCheckOutButtonImage, for: .normal)
                    self.warningBanner.isHidden = _isUserInGeoFence.0!
                } else {
                    self.checkInButton.setImage(checkInCheckOutImage.checkOutButtonImage, for: .normal)
                    self.warningBanner.isHidden = true
                }
                
                if savingData != nil {
                    if let overWriteData = self.shouldOverWrite(data: savingData!) {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(overWriteData)
                            realm.add(savingData!)
//                            overWriteData.building = savingData!.building
                        }
                    } else if self.shouldSave(data: savingData!) {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(savingData!)
                        }
                    }
                }
                self.getPunchingHistory()
            } else {
                var displayMessage = message
                if status {
                    displayMessage = "Something went wrong. Please check your network and try again later."
                }
                self.showAlert(message: displayMessage, title: "Oops")
            }
        }
    }
    
    func clockOut(isForced: Bool = false) {
        if !isUpdatingLocation {
            locationManager.startUpdatingLocation()
             self.view.showLoaderAnimation(loaderType: .loading, message: "Updating Location", animationViewSizeMultiplier: animationSize)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.view.hideLoaderAnimation()
                self.clockOut(isForced: isForced)
            }
        } else {
            let params: [String : Any] = ["client_id":Int(JaniTime.user.client_id) ?? 0, "building_id": Int(JaniTime.user.building_id) ?? 0, "employee_id": Int(JaniTime.user.user_id) ?? 0, "action" : "clock-out", "latitude": currentLocation!.coordinate.latitude, "longitude": currentLocation!.coordinate.longitude, "is_forced" : isForced]
            self.view.showLoaderAnimation(loaderType: .loading, message: "Clocking Out", animationViewSizeMultiplier: animationSize)
            API().callAPI(params: params, APItype: .clock_in_out, APIMethod: .post) { (message, status) in
                self.view.hideLoaderAnimation()
                if status {
                    self.shouldUpdateLocation = false
                    self.handleTimer(timerStart: false)
                    self.switchingCount = 0
                    self.getPunchingHistory()
                    self.progressRing.isHidden = true
                } else {
                    self.showAlert(message: message, title: "Oops")
                }
            }
        }
    }
    
    func getPunchingHistory() {
        let params: [String : Int] = ["user_id": Int(JaniTime.user.user_id) ?? 0, "client_id": Int(JaniTime.user.client_id)!]
        api.callAPI(params: params, APItype: .punchingHistory, APIMethod: .post) { (message, status) in
            if status {
                DispatchQueue.main.async {
                    self.homeTable.reloadData()
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let checkInVC = segue.destination as? DataEntryController {
            checkInVC.delegate = self
        }
        else if let savedCheckInVC = segue.destination as? SavedCheckInController {
            savedCheckInVC.delegate = self
            if getSavedCheckIn {
                savedCheckInVC.selectedDisplayData = .savedCheckIn
            } else {
                savedCheckInVC.selectedDisplayData = .companyList
            }
        }
    }
//    var updateCount = 0
    var isFirstCheck = true
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        isUpdatingLocation = true
        if currentLocation != nil {
            if location.distance(from: currentLocation!) > 10 {
                Logger.print("Original Location \(currentLocation!.coordinate.latitude)")
                
                currentLocation = location
                gotCurrentStatus = false
                DispatchQueue.main.async {
                    self.homeTable.reloadData()
                }
            }
        }
        else {
            currentLocation = location
            Logger.print("Original Location")
            DispatchQueue.main.async {
                self.homeTable.reloadData()
            }
        }
        
        if currentLocation != nil && !gotCurrentStatus{
            if currentLocation != nil && shouldUpdateLocation {
                if lastUpdatedTime == nil {
                    getCurrentStatus(withAnimation: isFirstCheck)
                    lastUpdatedTime = Date()
                } else {
                    let (_, _, _seconds, _) = JaniTime().timeAgoSinceDate(date: lastUpdatedTime! as NSDate, numericDates: false)
                    
                    if _seconds != nil, _seconds! > 7 {
                        getCurrentStatus(withAnimation: isFirstCheck)
                        lastUpdatedTime = Date()
                    }
                }
                
                let _isUserInGeoFence = isUserInGeoFence()
                
                if _isUserInGeoFence.0 != nil {
                    if isTimerRunning {
                        if !_isUserInGeoFence.0! {
                            //                            self.progressRing.isHidden = false
                        self.checkInButton.setImage(checkInCheckOutImage.forcedCheckOutButtonImage, for: .normal)
                            self.warningBanner.isHidden = _isUserInGeoFence.0!
                        } else {
                            self.progressRing.isHidden = true
                        self.checkInButton.setImage(checkInCheckOutImage.checkOutButtonImage, for: .normal)
                            self.warningBanner.isHidden = true
                        }
                    }
                    if !_isUserInGeoFence.0! && !dispatchedWarningNotification && isTimerRunning {
                        
                        
                        showWarningNotification(title: "Warning", body: (JaniTime.user.employeeAutoClockOut) ? "You have left your building - you have 50 seconds to re-enter before you are automatically clocked out" : "You have left your building - Forgot to clock-out?")
                        
                        
                    } else if _isUserInGeoFence.0! {
                        dispatchedWarningNotification = false
                    }
                }
            }
            getCurrentStatus(withAnimation: isFirstCheck)
            isFirstCheck = false
        } else {
            if currentLocation == nil {
                showLocationWarning()
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        } else if status == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 10
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        } else if status == .denied || status == .notDetermined {
            currentLocation = nil
            showLocationWarning()
        }
    }
    @IBAction func savedButtonAct(_ sender: Any) {
        if JaniTime.user.client_id != "" {
            getSavedCheckIn = true
        }
        if !isTimerRunning {
            goToSavedCheckIn()
        }
        
    }
    
    func getCurrentStatus(withAnimation: Bool = true) {
        if currentLocation != nil {
            let params: [String : Any] = ["client_id" : Int(JaniTime.user.client_id) ?? 0, "building_id" : Int(JaniTime.user.building_id) ?? 0, "employee_id": Int(JaniTime.user.user_id) ?? 0, "latitude": Float(currentLocation!.coordinate.latitude), "longitude": Float(currentLocation!.coordinate.longitude)]
            Logger.print(params)
            if withAnimation {
                self.view.showLoaderAnimation(loaderType: .loading, message: "Fetching Status", animationViewSizeMultiplier: animationSize)
            }
            api.callAPI(params: params, APItype: .clock_current, APIMethod: .post) { (message, status) in
                self.view.hideLoaderAnimation()
                if status && message != "clocked-out"{
                    let time = Date(timeIntervalSince1970: JaniTime.parsingData.clockInData!.clock_time_in)
                    self.gotCurrentStatus = true
                    self.handleTimer(timerStart: true, time: time)
                } else {
                    //                self.handleTimer(timerStart: false, time: Date())
                }
            }
        } else {
            showLocationWarning()
        }
        
    }
    
    
    func showAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateLocation() {
//        if switchingCount > 2 {
//            currentLocation = changingLocation
//            if let fullMapCell = homeTable.cellForRow(at: IndexPath(row: 0, section: 1)) as? CheckedInFullMapCell {
//                fullMapCell.fullMapView.animate(toLocation: changingLocation.coordinate)
//            }
//            Logger.print("Changed Location")
//        }
//        switchingCount += 1
        if JaniTime.parsingData.clockInData != nil, JaniTime.parsingData.clockInData!.building_location != nil {
            Logger.print("@=\(currentLocation!.distance(from: JaniTime.parsingData.clockInData!.building_location!))=@")
        }
        let timeStamp = Date().timeIntervalSince1970
        let params: [String : Any] = ["client_id" : Int(JaniTime.user.client_id) ?? 0, "building_id" : Int(JaniTime.user.building_id) ?? 0, "employee_id": Int(JaniTime.user.user_id) ?? 0, "latitude": isUpdatingLocation ?  currentLocation!.coordinate.latitude : 0, "longitude": isUpdatingLocation ?  currentLocation!.coordinate.longitude : 0, "time_stamp": timeStamp]

        api.callAPI(params: params, APItype: .clock_current, APIMethod: .post) { (message, status) in
//            self.lastUpdatedTime = Date()
            
            if JaniTime.user.hasAutoClockedOut {
                self.shouldUpdateLocation = false
                self.handleTimer(timerStart: false, time: Date())
                if !self.dispatchedLocalNotification {
                    _ = LocalNotification.dispatchlocalNotification(with: "Clock-Out", body: "System clocked you out since you went outside the building radius", timeAfter: 1, identifier: LocalNotification.notificationIdentifiers.clockedOut)
                    self.dispatchedLocalNotification = true
                    self.showAlert(message: "System clocked you out since you went outside the building radius", title: "Clock-out")
                }
                self.getPunchingHistory()
            }
            
//                else {
//                self.handleTimer(timerStart: false, time: Date())
//                if !self.dispatchedLocalNotification {
//                    _ = LocalNotification.dispatchlocalNotification(with: "Clock-Out", body: "System clocked you out since you went outside the building radius", timeAfter: 1, identifier: LocalNotification.notificationIdentifiers.clockedOut)
//                    self.dispatchedLocalNotification = true
//                    self.showAlert(message: "System clocked you out since you went outside the building radius", title: "Clock-out")
//                }
//                self.getPunchingHistory()
//            }
        }
    }
    
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.homeTable.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    func shouldSave(data: Preferences) -> Bool {
        let realm = try! Realm()
        let objects = realm.objects(Preferences.self)
        for object in objects {
            if areRealmObjectsEqual(objectA: object, objectB: data) {
                return false    
            }
        }
        return true
    }
    
    func shouldOverWrite(data: Preferences) -> Preferences? {
        let realm = try! Realm()
        let objects = realm.objects(Preferences.self)
        for object in objects {
            if canOverWrite(objectA: object, objectB: data) {
                return object
            }
        }
        return nil
    }
    
    func areRealmObjectsEqual(objectA: Preferences, objectB: Preferences) -> Bool {
        if (objectA.managerCode == objectB.managerCode) && (objectA.managerType == objectB.managerType) && (objectA.buildingId == objectB.buildingId) && (objectA.userType == objectB.userType){
            if objectA.building == objectB.building {
                return true
            }
        }
        return false
    }
    
    func canOverWrite(objectA: Preferences, objectB: Preferences) -> Bool {
        if (objectA.managerCode == objectB.managerCode) && (objectA.managerType == objectB.managerType) && (objectA.buildingId == objectB.buildingId) && (objectA.userType == objectB.userType){
            if objectA.building != objectB.building {
                return true
            }
        }
        return false
    }
    
    
    func selectedCompany() {
        if JaniTime.user.client_company != "" {
            titleLabel.text = JaniTime.user.client_company
        } else {
            titleLabel.text = "Home"
        }
    }
    
    
    @IBAction func clearAct(_ sender: Any) {
        clearAlert()
    }
    
    func clearConfirmed() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        let domain = Bundle.main.bundleIdentifier!
        JaniTime.userDefaults.removePersistentDomain(forName: domain)
        JaniTime.parsingData.punchingHistory.removeAll()
        JaniTime.userDefaults.synchronize()
        self.view.showLoaderAnimation(loaderType: .loading, message: "Resetting", animationViewSizeMultiplier: animationSize)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            JaniTime.appDelegate.resetAppToFirstController(sBID: Constants.StoryBoardID.initialVC)
        }
//        getCompanyList()
    }
    
    func clearAlert() {
        let clearAlert = UIAlertController(title: "Logout", message: "Are you sure you want to log out of the app?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.clearConfirmed()
        }
        
        let noAction = UIAlertAction(title: "No", style: .destructive) { (action) in
            
        }
        clearAlert.addAction(yesAction)
        clearAlert.addAction(noAction)
        
        present(clearAlert, animated: true, completion: nil)
        
    }
    
    
    
    func isUserInGeoFence() -> (Bool?, String?) {
        if !JaniTime.user.employeeAutoClockOut && false {
            return (true,"Inside")
            //No need to show warning message if the system auto clockout is turned off
        }
        if JaniTime.parsingData.clockInData != nil, JaniTime.parsingData.clockInData!.building_location != nil, currentLocation != nil {
            let circleCenter = JaniTime.parsingData.clockInData!.building_location!
            let userDistance = circleCenter.distance(from: currentLocation!)
            if userDistance > JaniTime.parsingData.clockInData!.building_radius {
                //outside geofence
                return(false, "Outside")
            } else {
                //inside geofence
                return(true, "Inside")
            }
        }
        else {
            return (nil, nil)
        }
    }
    
    func showWarningNotification(title: String, body: String) {
        _ = LocalNotification.dispatchlocalNotification(with: title, body: body, timeAfter: 1, identifier: LocalNotification.notificationIdentifiers.willClockOut)
        self.showAlert(message: body, title: title)
        self.dispatchedWarningNotification = true
    }
    
    func showLocationWarning() {
        showAlert(message: "Location is not available right now. Please allow JaniTime to access location, in Settings", title: "Error")
//        locationManager.requestWhenInUseAuthorization()
    }
    
    @objc func longPressAct(_ sender: UILongPressGestureRecognizer) {
        if isTimerRunning {
            if sender.state == .began {
                progressRing.value = 1
                progressRing.startProgress(to: 0, duration: 0.05)
                //            tripSpeedometerView.startProgress(to: 1, duration: 0.1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.progressRing.startProgress(to: 99, duration: 2.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if self.progressRing.value == 99 {
                            let warningMessage = "Are you sure you want to clock-out?"
                            let okAction = UIAlertAction(title: "Clock Out", style: .default, handler: { (action) in
                                self.clockOut(isForced: true)
                            })
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                                
                            })
                            let longPressAlert = UIAlertController(title: "JaniTime", message: warningMessage, preferredStyle: .alert)
                            longPressAlert.addAction(okAction)
                            longPressAlert.addAction(cancelAction)
                            self.present(longPressAlert, animated: true, completion: nil)
                            self.progressRing.startProgress(to: 100, duration: 1.0)
                        }
                    }
                }
                
            } else if sender.state == .ended {
                if progressRing.isAnimating {
                    progressRing.pauseProgress()
                }
                if progressRing.value < 100 {
                    //                tripSpeedometerView.value = 100
                    progressRing.startProgress(to: 0, duration: 1.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.progressRing.startProgress(to: 100, duration: 0.05)
                        
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.progressRing.startProgress(to: 100, duration: 1.0)
                    }
                }
            }
            
        }
    }
}


