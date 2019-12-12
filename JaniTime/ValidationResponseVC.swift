//
//  ValidationResponseVC.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 22/04/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import UIKit

protocol ResponseProtocol {
    func doneClicked(response: ValidationResponse)
}
enum ValidationResponse {
    case success
    case error
}

class ValidationResponseVC: UIViewController {

    @IBOutlet weak var responseTitle: UILabel!
    
    @IBOutlet weak var responseMessage: UILabel!
    
    var pageTitle = ""
    var pageMessage = ""
    
    var delegate: ResponseProtocol? = nil
    
    var responseType: ValidationResponse = .success
    
    @IBOutlet weak var responseImage: UIImageView!
    
    struct responseImages {
        static let success_tick = UIImage(named: "success_tick")
        static let error_cross = UIImage(named: "error_cross")
    }
    
    @IBOutlet weak var errorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.layer.cornerRadius = 10.0
        
        responseImage.isHidden = true
        responseTitle.isHidden = true
        responseMessage.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneAct(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.doneClicked(response: self.responseType)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Logger.print(pageMessage)
        responseMessage.text = pageMessage
        setStatus()
    }
    
    func setStatus() {
        
        switch responseType {
        case .success:
            responseTitle.text = "Success"
            responseTitle.textColor = UIColor(hex: "6ac259")
            responseImage.image = responseImages.success_tick
        case .error:
            responseTitle.text = "Error"
            responseTitle.textColor = UIColor(hex: "f05228")
            responseImage.image = responseImages.error_cross
        }
        responseImage.isHidden = false
        responseTitle.isHidden = false
        responseMessage.isHidden = false
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
