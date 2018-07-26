//
//  CreateLineViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/24/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreateLineViewController: UIViewController, UITextFieldDelegate {
    
    let currentUser = User.current
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var maxMembersTextField: UITextField!
    @IBOutlet weak var waitTimeTextFieldHours: UITextField!
    @IBOutlet weak var waitTimeTextFieldMinutes: UITextField!
    @IBOutlet weak var waitTimeTextFieldSeconds: UITextField!
    
    @IBAction func createLineButtonPressed(_ sender: Any) {
        let rootRef = Database.database().reference()
        let lineRef = rootRef.child("lines")
        if nameTextField.text == nil || nameTextField.text == "" {
            createErrorPopUp("nameTextField is empty!")
            return
        }
        let lineName: String = nameTextField.text!
        guard let maxMembers: Int = Int(maxMembersTextField.text!) else {
            createErrorPopUp("maxMembersTextField is empty!")
            return
        }
        guard let waitTimeHours: Int = Int(waitTimeTextFieldHours.text!) else {
            createErrorPopUp("waitTimeTextFieldHours is empty!")
            return
        }
        guard let waitTimeMinutes: Int = Int(waitTimeTextFieldMinutes.text!) else {
            createErrorPopUp("waitTimeTextFieldMinutes is empty!")
            return
        }
        guard let waitTimeSeconds: Int = Int(waitTimeTextFieldSeconds.text!) else {
            self.createErrorPopUp("waitTimeTextFieldSeconds is empty!")
            return
        }
        lineRef.child(lineName).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Any] {
                self.createErrorPopUp("line named \(lineName) already exists!")
                return
            } else {
                lineRef.child(lineName).setValue(["creator": self.currentUser.username, "maxMembers": maxMembers, "waitTime": waitTimeHours*3600+waitTimeMinutes*60+waitTimeSeconds])
                return
            }
        })
    }
    
    @IBAction func waitTimeMinutesDidChange(_ sender: UITextField!) {
        guard let value: Int = Int(sender.text!) else {
            return
        }
        if value >= 60 {
            sender.text = "59"
        }
    }
    
    @IBAction func waitTimeSecondsDidChange(_ sender: UITextField!) {
        guard let value: Int = Int(sender.text!) else {
            return
        }
        if value >= 60 {
            sender.text = "59"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        maxMembersTextField.delegate = self
        waitTimeTextFieldHours.delegate = self
        waitTimeTextFieldMinutes.delegate = self
        waitTimeTextFieldSeconds.delegate = self
        nameTextField.placeholder = "\(currentUser.username)'s Line"
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if textField == nameTextField {
            return newString.length <= 20
        } else if textField == maxMembersTextField {
            return newString.length <= 8
        } else if textField == waitTimeTextFieldHours {
            return newString.length <= 7
        } else if textField == waitTimeTextFieldMinutes || textField == waitTimeTextFieldSeconds {
            return newString.length <= 2
        }
        return true
    }
    
    func createErrorPopUp(_ message: String) {
        print(message)
    }
}
