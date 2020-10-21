//
//  InitialEntryVC.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 22/04/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit

class InitialEntryVC: UIViewController, ResponseProtocol {
    @IBOutlet weak var pageTitle: UILabel!
    
    @IBOutlet weak var companyCodeField: UITextField!
    
    @IBOutlet weak var employeeIdField: UITextField!
    
    @IBOutlet weak var privacyLabel: UILabel!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let api = API()
    
    var animationSize: CGFloat = 0.1
    
    // This Method is loaded once in view controller life cycle. Its Called When all the view are loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        employeeIdField.delegate = self
        privacyLabel.text = "Janitime tracks your location in the background *only* while you are clocked in."
        privacyLabel.lineBreakMode = .byWordWrapping
        
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        let fields = [companyCodeField, employeeIdField]
        for each in fields {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: each!.frame.size.height))
            each!.leftView = paddingView
            each!.leftViewMode = .always
            each!.layer.cornerRadius = 5.0
            each!.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            each!.layer.borderWidth = 1.0
        }
    }
    func canProceed() -> (Bool, String?) {
        if companyCodeField.text != nil && employeeIdField.text != nil {
            if companyCodeField.text! == "" || employeeIdField.text! == "" {
                return (false, nil)
            } else if employeeIdField.text!.count != 6 {
                return (false, "Employee Id should be 6 digits long")
            }
        } else {
            return (false, nil)
        }
        
        return (true, nil)
    }

    @IBAction func doneAct(_ sender: Any) {
        let _canProceed = canProceed()
        if _canProceed.0 {
            validateData()
        } else {
            let message = _canProceed.1 == nil ? "Please enter valid data" : _canProceed.1!
            showAlert(message: message , title: "Oops")
        }
    }
    
    func validateData() {
        let params: [String : Int] = ["client_id": Int(companyCodeField.text!)!, "employee_id": Int(employeeIdField.text!)!]
        self.view.showLoaderAnimation(loaderType: .loading, message: "Validating", animationViewSizeMultiplier: animationSize)
        api.callAPI(params: params, APItype: .validate_employee, APIMethod: .post) { (message, status) in
            self.view.hideLoaderAnimation()
            if status {
                self.show(response: .success)
                JaniTime.user.user_id = self.employeeIdField.text!
                JaniTime.user.client_id = self.companyCodeField.text!
            } else {
                self.show(response: .failure)
            }
        }
    }
    
    func showAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    enum validationResponse {
        case success
        case failure
    }
    
    func show(response: validationResponse) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let alert = storyBoard.instantiateViewController(withIdentifier: "ValidationResponseVC") as? ValidationResponseVC
        {
            alert.delegate = self
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            alert.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            if response == .success {
                alert.responseType = .success
                alert.pageMessage = "The chosen company code is allocated to you, please clock in from home-screen to track your duration with Janitime"
            } else {
                alert.responseType = .error
                alert.pageMessage = "The chosen company code is not allocated to you, please contact company admin"
            }
            present(alert, animated: true, completion: nil)
        }
    }
    
    func doneClicked(response: ValidationResponse) {
        if response == .success {
            JaniTime.appDelegate.resetAppToFirstController(sBID: Constants.StoryBoardID.defaultVC)
        }
        
    }
    
    @IBAction func getCodeAct(_ sender: Any) {
        guard let url = URL(string: "https://app.janitime.com/login.php") else { return }
        UIApplication.shared.open(url)
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
extension InitialEntryVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 6
    }
}
