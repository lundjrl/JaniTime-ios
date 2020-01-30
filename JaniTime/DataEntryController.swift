//
//  DataEntryController.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 08/03/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit
import CZPicker
import IQKeyboardManager
import RealmSwift

protocol DataEntryDelegate {
    func dataEntered(data: clockInData, savingData: Preferences?)
}

extension DataEntryDelegate {
    func selectedCompany() {
        
    }
}

class DataEntryController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CZPickerViewDelegate, CZPickerViewDataSource, DataEntryDelegate {

    var dataList = ["Employee ID", "Building ID"]
    var dataEntries = [String : String]()
    
    @IBOutlet weak var dataTable: UITableView!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
//    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    let pickerItems = ["Manager", "User"]
    let managerTypes = ["General Manager", "Training", "Filling In"]
//    Regular Manager -> 0
//    Manager Training -> 1
//    Manager Filling In -> 2
    
//    General Manager
//
//    Filling in
//    Training
    let typePickerView = CZPickerView(headerTitle: "User Type", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
    let managerPicker = CZPickerView(headerTitle: "Manager Type", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
    
    var delegate: DataEntryDelegate? = nil
    
    @IBOutlet weak var managerSwitch: UISwitch!
    
    @IBOutlet weak var managerLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    var savingData: Preferences? = nil
    
    struct checkbox_images {
        static let checked = UIImage(named: "checked_box")
        static let unchecked = UIImage(named: "unchecked_box")
    }
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var checkButton: UIButton!
    
    var shouldSave: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        idLabel.text = JaniTime.user.client_company
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide
        let dataNib = UINib(nibName: "DataCell", bundle: nil)
        dataTable.register(dataNib, forCellReuseIdentifier: "DataCell")
        for each in dataList {
            if each == "Employee ID" {
                dataEntries[each] = JaniTime.user.user_id
            } else {
                dataEntries[each] = ""
            }
            
        }
        dataTable.bounces = false
    
        typePickerView!.allowMultipleSelection = false
        typePickerView!.needFooterView = false
        typePickerView!.headerBackgroundColor = UIColor(hex: "2c99f2")
        typePickerView!.delegate = self
        typePickerView!.dataSource = self
        
        managerPicker!.allowMultipleSelection = false
        managerPicker!.needFooterView = false
        managerPicker!.headerBackgroundColor = UIColor(hex: "2c99f2")
        managerPicker!.delegate = self
        managerPicker!.dataSource = self
        
        setCheckBox()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        tableHeight.constant = dataTable.contentSize.height + 30
    }
    
    @IBAction func doneAct(_ sender: Any) {
        if isPageComplete() {
            var selectData = clockInData()
            JaniTime.user.user_id = dataEntries["Employee ID"]!
            selectData.building_id = Int(dataEntries["Building ID"]!) ?? 0
            selectData.employee_id = Int(dataEntries["Employee ID"]!) ?? 0
            selectData.manager_code = Int(dataEntries["Manager Code"] ?? "") ?? 0
            if currentLocation != nil {
                selectData.latitude = currentLocation!.coordinate.latitude
                selectData.longitude = currentLocation!.coordinate.longitude
            }
            
//            selectData.user_type = (dataEntries["User Type"]?.lowercased())!
            selectData.user_type = (managerSwitch.isOn) ? "manager" : "user"
            Logger.print(selectData)
            delegate?.dataEntered(data: selectData, savingData: savingData)
            self.navigationController?.popViewController(animated: true)
//            selectData.
        } else {
            showAlert(message: "Please make sure that all entries are valid", title: "Oops")
        }
    }
    
    
    @IBAction func cancelAct(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dataCell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as? DataCell {
            dataCell.dataField.placeholder = dataList[indexPath.section]
            if dataCell.dataField.placeholder!.contains("Name") {
                dataCell.dataField.placeholder = "Enter Name to save for later"
            }
            if dataList[indexPath.section] == "Employee ID" {
                if let _id = dataEntries[dataList[indexPath.section]] as? String {
                    if let _idValue = Int(_id) {
                        let _paddingID = String(format: "%05d", _idValue)
                        dataCell.dataField.text = _paddingID
                    } else {
                        dataCell.dataField.text = dataEntries[dataList[indexPath.section]]
                    }
                } else {
                    dataCell.dataField.text = dataEntries[dataList[indexPath.section]]
                }
            } else {
                dataCell.dataField.text = dataEntries[dataList[indexPath.section]]
            }
            
            dataCell.dataField.delegate = self
            if indexPath.section == 0 {
                dataCell.dataField.isUserInteractionEnabled = false
            }
            if dataList[indexPath.section] == "Manager Code" {
                let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:30, height: dataCell.dataField.frame.height))
                let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                imageView.contentMode = .scaleAspectFit
                imageView.image = UIImage(named: "dropdownImage")
                containerView.addSubview(imageView)
                imageView.center = containerView.center
                dataCell.dataField.rightView = containerView
                dataCell.dataField.rightViewMode = .always
                dataCell.dataField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                if let managerIndex = Int(dataEntries["Manager Code"] ?? "") {
                    if managerIndex > 0 {
                        dataCell.dataField.text = managerTypes[managerIndex - 1]
                    }
                }
                
            } else {
                dataCell.dataField.rightView = nil
            }
            if dataList[indexPath.section] == "Employee ID" || dataList[indexPath.section] ==  "Building ID" {
                dataCell.dataField.keyboardType = .numberPad
            }
            return dataCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.placeholder == "Manager Code" {
            return false
        }
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if textField.placeholder!.contains("Name to save") {
            dataEntries["Name"] = updatedString
        } else {
            dataEntries[textField.placeholder!] = updatedString
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.placeholder == "Manager Code" {
            self.view.endEditing(true)
            managerPicker!.show()
            return false
        }
        return true
    }
    

    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        if pickerView == managerPicker {
            return managerTypes.count
        }
        return 0
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        if pickerView == managerPicker {
            return managerTypes[row]
        }
        return ""
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        if pickerView == typePickerView {
            if let cell = dataTable.cellForRow(at: IndexPath(row: 0, section: 1)) as? DataCell {
                cell.dataField.text = pickerItems[row]
                dataEntries[dataList[1]] = pickerItems[row]
                if pickerItems[row] == "Manager" && dataList.count == 3 {
                    dataList.insert("Manager Code", at: 2)
                    DispatchQueue.main.async {
                        self.dataTable.reloadData()
                        self.tableHeight.constant = self.dataTable.contentSize.height + 30
                    }
                } else if pickerItems[row] == "User" && dataList.count == 4 {
                    dataList.remove(at: 2)
                    DispatchQueue.main.async {
                        self.dataTable.reloadData()
                        self.tableHeight.constant = self.dataTable.contentSize.height + 30
                    }
                }
            }
        } else {
            if let cell = dataTable.cellForRow(at: IndexPath(row: 0, section: 1)) as? DataCell {
                if cell.dataField.placeholder == "Manager Code" {
                    cell.dataField.text = managerTypes[row]
                    dataEntries["Manager Code"] = "\(row + 1)"
                }
            }
        }
    }
    
    
    func saveData() -> Preferences? {
        let _userId = dataEntries["Employee ID"]
        let _buildingId = dataEntries["Building ID"]
        let _userType = (managerSwitch.isOn) ? "manager" : "user"
        let _name = dataEntries["Name"]
        var _code = ""
        if managerSwitch.isOn && dataEntries["Manager Code"] != nil {
            _code = dataEntries["Manager Code"]!
        }
        let splitCode = _code.components(separatedBy: ".")
        var _managerCode = Int(_code) ?? 0
        var _managerType = ""
        if splitCode.count > 1 {
            _managerCode = Int(splitCode[0]) ?? 0
            _managerType = splitCode[1]
        }
        let _date = Date()
        let preferences = Preferences()
        preferences.building = _name ?? ""
        preferences.userId = _userId ?? ""
        preferences.buildingId = _buildingId ?? ""
        preferences.userType = _userType
        if currentLocation != nil {
            preferences.latitude = currentLocation!.coordinate.latitude
            preferences.longitude = currentLocation!.coordinate.longitude
        }
        preferences.date = _date
        preferences.managerCode = _managerCode
        preferences.managerType = _managerType
        
        
        return preferences
        
        
    }
    
    
    func isPageComplete() -> Bool {
//        var flag = true
        for each in dataList {
            if dataEntries[each] == "" && each != "Name" {
                return false
            }
        }
        if dataEntries["Name"] != "" {
            let realm = try! Realm()
            let data = realm.objects(Preferences.self)
            if shouldSave {
                savingData = saveData()
            } 
            
        }
        return true
    }
    
    func dataEntered(data: clockInData, savingData: Preferences?) {
//        var dataList = ["Employee ID", "Building ID", "User Type", "Name"]
        dataEntries["Employee ID"] = "\(data.employee_id)"
        dataEntries["Building ID"] = "\(data.building_id)"
        dataEntries["User Type"] = data.user_type
        dataEntries["Manager Code"] = "\(data.manager_code)"
        if data.manager_code > 0 {
            self.managerSwitch.setOn(true, animated: false)
            if dataList.count == 2 {
                dataList.insert("Manager Code", at: 1)
                DispatchQueue.main.async {
                    self.dataTable.reloadData()
                            self.tableHeight.constant = self.dataTable.contentSize.height + 30
                }
            }
        }
        DispatchQueue.main.async {
            self.dataTable.reloadData()
        }
    }
    
    @IBAction func switchAct(_ sender: Any) {
        if managerSwitch.isOn && dataList.count == 2 {
            dataList.insert("Manager Code", at: 1)
            dataEntries["Manager Code"] = ""
            DispatchQueue.main.async {
                self.dataTable.reloadData()
                self.tableHeight.constant = self.dataTable.contentSize.height + 30
            }
        } else if !managerSwitch.isOn && dataList.count == 3 {
            dataList.remove(at: 1)
            dataEntries["Manager Code"] = ""
            DispatchQueue.main.async {
                self.dataTable.reloadData()
                self.tableHeight.constant = self.dataTable.contentSize.height + 30
            }
        }
    }
    
    
    func goToSavedList() {
        performSegue(withIdentifier: Constants.Segue.CHECKIN_SAVED, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SavedCheckInController {
            destination.delegate = self
            destination.selectedDisplayData = .savedCheckIn
        }
    }
    
    @IBAction func savedAction(_ sender: Any) {
        goToSavedList()
    }
    
    
    func showAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func checkAction(_ sender: Any) {
        shouldSave = !shouldSave
        setCheckBox()
    }
    
    func setCheckBox() {
        if shouldSave {
            checkButton.setImage(checkbox_images.checked, for: .normal)
        } else {
            checkButton.setImage(checkbox_images.unchecked, for: .normal)
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
