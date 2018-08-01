//
//  PopUpSerice.swift
//  Line Up App
//
//  Created by Macbook on 7/31/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit

protocol PopUpViewControllerListener {
    var popUpInput: String? { get set }
    func popUpResponse(identifier: String)
}

class PopUpViewController: UIViewController {
    
    var forceAction: Bool = false
    var identifier: String = ""
    var destination: PopUpViewControllerListener?
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var inputConfirmButton: UIButton!
    @IBOutlet weak var inputCancelButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func yesButtonPressed(_ sender: Any) {
        destination?.popUpResponse(identifier: identifier)
        dismiss(animated: true) {}
    }
    
    @IBAction func noButtonPressed(_ sender: Any) {
        dismiss(animated: true) {}
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if forceAction {
            destination?.popUpResponse(identifier: identifier)
        }
        dismiss(animated: true) {}
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        destination?.popUpInput = inputTextField.text != nil ? inputTextField.text! : ""
        destination?.popUpResponse(identifier: identifier)
        dismiss(animated: true) {}
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true) {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 15
        popUpView.layer.shadowColor = UIColor.black.cgColor
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 5)
        popUpView.layer.shadowOpacity = 0.6
        popUpView.layer.shadowRadius = 5
    }
}

// Do not call pop-up functions in viewDidLoad() and viewWillAppear()
extension UIViewController {
    func createErrorPopUp(_ message: String) -> PopUpViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! PopUpViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        vc.doneButton.isHidden = false
        vc.yesButton.isHidden = true
        vc.noButton.isHidden = true
        vc.doneButton.isEnabled = true
        vc.yesButton.isEnabled = false
        vc.noButton.isEnabled = false
        vc.inputTextField.isEnabled = false
        vc.inputConfirmButton.isEnabled = false
        vc.inputTextField.isHidden = true
        vc.inputConfirmButton.isHidden = true
        vc.inputCancelButton.isEnabled = false
        vc.inputCancelButton.isHidden = true
        vc.messageLabel.text = message
        vc.forceAction = false
        
        return vc
    }

    func confirmAction(_ message: String, identifier: String, sender: PopUpViewControllerListener) -> PopUpViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! PopUpViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        vc.doneButton.isHidden = true
        vc.yesButton.isHidden = false
        vc.noButton.isHidden = false
        vc.doneButton.isEnabled = false
        vc.yesButton.isEnabled = true
        vc.noButton.isEnabled = true
        vc.inputTextField.isEnabled = false
        vc.inputConfirmButton.isEnabled = false
        vc.inputTextField.isHidden = true
        vc.inputConfirmButton.isHidden = true
        vc.inputCancelButton.isEnabled = false
        vc.inputCancelButton.isHidden = true
        vc.messageLabel.text = message
        vc.identifier = identifier
        
        vc.destination = sender
        
        return vc
    }
    
    func getInput(_ message: String, identifier: String, sender: PopUpViewControllerListener) -> PopUpViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! PopUpViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        vc.doneButton.isHidden = true
        vc.yesButton.isHidden = true
        vc.noButton.isHidden = true
        vc.doneButton.isEnabled = false
        vc.yesButton.isEnabled = false
        vc.noButton.isEnabled = false
        vc.inputTextField.isEnabled = true
        vc.inputConfirmButton.isEnabled = true
        vc.inputTextField.isHidden = false
        vc.inputConfirmButton.isHidden = false
        vc.inputCancelButton.isEnabled = true
        vc.inputCancelButton.isHidden = false
        vc.messageLabel.text = message
        vc.identifier = identifier
        
        vc.destination = sender
        
        return vc
    }
    
    func forceActionPopUp(_ message: String, identifier: String, sender: PopUpViewControllerListener) -> PopUpViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! PopUpViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        vc.doneButton.isHidden = false
        vc.yesButton.isHidden = true
        vc.noButton.isHidden = true
        vc.doneButton.isEnabled = true
        vc.yesButton.isEnabled = false
        vc.noButton.isEnabled = false
        vc.inputTextField.isEnabled = false
        vc.inputConfirmButton.isEnabled = false
        vc.inputTextField.isHidden = true
        vc.inputConfirmButton.isHidden = true
        vc.inputCancelButton.isEnabled = false
        vc.inputCancelButton.isHidden = true
        vc.messageLabel.text = message
        vc.identifier = identifier
        vc.forceAction = true
        
        vc.destination = sender
        
        return vc
    }
}

