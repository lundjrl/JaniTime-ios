//
//  SavedCheckInController.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 08/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//


import UIKit
import RealmSwift


class SavedCheckInController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var checkInTable: UITableView!
    
    let realm = try! Realm()
    
    @IBOutlet weak var checkInSearch: UISearchBar!
    
    enum displayData {
        case savedCheckIn
        case companyList
    }
    var selectedDisplayData = displayData.savedCheckIn
//    var selectedDisplayData = [Any].self
    
    var delegate: DataEntryDelegate? = nil
    
//    var displayCheckedinList: Results<Preferences>? = nil
    var displayCheckedinList: [Preferences] = []
    var displayCompanyList: [ParsingData.CompanyTemplate] = JaniTime.parsingData.companyList
    
    @IBOutlet weak var pageTitle: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    let managerTypes = ["General Manager", "Training", "Filling In"]
    
    // This Method is loaded once in view controller life cycle. Its Called When all the view are loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        let data = realm.objects(Preferences.self)
        displayCheckedinList = Array(data.reversed())

        Logger.print(displayCheckedinList)
        let checkInNib = UINib(nibName: "SavedCheckInCell", bundle: nil)
        checkInTable.register(checkInNib, forCellReuseIdentifier: "SavedCheckInCell")
        
        let countryNib = UINib(nibName: "CompanyListCell", bundle: nil)
        checkInTable.register(countryNib, forCellReuseIdentifier: "CompanyListCell")
        if selectedDisplayData == .companyList {
            pageTitle.text = "Select Company"
            backButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedDisplayData == .savedCheckIn {
            Logger.print(displayCheckedinList)
            return displayCheckedinList.count
        } else {
            return displayCompanyList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedDisplayData == .companyList {
            if let companyCell = tableView.dequeueReusableCell(withIdentifier: "CompanyListCell") as? CompanyListCell {
                let company = displayCompanyList[indexPath.row]
                companyCell.companyName.text = "\(company.client_company)-\(company.client_id)"
                return companyCell
            }
        }
        else if let checkInCell = tableView.dequeueReusableCell(withIdentifier: "SavedCheckInCell") as?  SavedCheckInCell {
//            let data = realm.objects(Preferences.self)[indexPath.row]
            let data = displayCheckedinList[indexPath.row]
            checkInCell.buildingName.text = data.buildingId
            var _paddingID = data.userId
            if let _idValue = Int(data.userId) {
                _paddingID = String(format: "%05d", _idValue)
            }
            checkInCell.userBuildingId.text = "Employee Id:\(_paddingID), Building ID:\(data.buildingId)"
            checkInCell.userType.text = "User Type:\(data.userType.capitalized)"
            print(data.managerCode)
            if data.userType.contains("nager") {
                if managerTypes.count >= (data.managerCode - 1) && (data.managerCode > 0) {
                    checkInCell.userType.text = "Manager Type: \(managerTypes[data.managerCode-1])"
                }
                
            }
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm a"
            
            let dateString = dateFormatter.string(from: data.date)
            let timeString = timeFormatter.string(from: data.date)
            
            checkInCell.dateLabel.text = dateString
            checkInCell.timeLabel.text = timeString
            
            return checkInCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedDisplayData == .savedCheckIn {
            return 100.0
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedDisplayData == .companyList {
            let selectedCompany = displayCompanyList[indexPath.row]
            JaniTime.user.client_id = selectedCompany.client_id
            JaniTime.user.client_company = selectedCompany.client_company
            if delegate != nil {
                delegate!.selectedCompany()
            }
        }
        else {
            let data = displayCheckedinList[indexPath.row]
//            let data = realm.objects(Preferences.self)[indexPath.row]
            var selectData = clockInData()
            Logger.print(data)
            selectData.building_id = Int(data.buildingId) ?? 0
            selectData.employee_id = Int(data.userId) ?? 0
            selectData.latitude = data.latitude
            selectData.longitude = data.longitude
            selectData.user_type = data.userType.lowercased()
            selectData.manager_code = data.managerCode
            selectData.name = data.building
            if delegate != nil {
                delegate!.dataEntered(data: selectData, savingData: nil)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func backAct(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if selectedDisplayData == .companyList {
            filterCompanyList(onData: searchText)
        } else {
            filterCheckInList(onData: searchText)
        }
    }
    
    func filterCheckInList(onData: String) {
        displayCheckedinList = []
        let data = realm.objects(Preferences.self)
        if onData == "" {
            displayCheckedinList = Array(data)
        } else {
            for each in data {
                if each.building.lowercased().contains(onData.lowercased()) {
                    displayCheckedinList.append(each)
                }
            }
        }
        DispatchQueue.main.async {
            self.checkInTable.reloadData()
        }
    }
    
    func filterCompanyList(onData: String) {
        displayCompanyList = []
        if onData == "" {
            displayCompanyList = JaniTime.parsingData.companyList
        } else {
            for each in JaniTime.parsingData.companyList {
                if each.client_company.lowercased().contains(onData.lowercased()) {
                    displayCompanyList.append(each)
                }
            }
        }
        DispatchQueue.main.async {
            self.checkInTable.reloadData()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
