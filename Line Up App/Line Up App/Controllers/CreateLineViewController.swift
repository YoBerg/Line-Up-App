//
//  CreateLineViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/24/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//
//204 199 182

import UIKit
import FirebaseDatabase

class CreateLineViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var nameTextField: ClosableTextField!
    @IBOutlet weak var maxMembersTextField: ClosableTextField!
    @IBOutlet weak var waitTimeTextFieldHours: ClosableTextField!
    @IBOutlet weak var waitTimeTextFieldMinutes: ClosableTextField!
    @IBOutlet weak var waitTimeTextFieldSeconds: ClosableTextField!
    @IBOutlet weak var endLocationTextField: ClosableTextField!
    @IBOutlet weak var messageTextField: ClosableTextView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func unwindWithSegue(segue: UIStoryboardSegue) {
    }
    @IBAction func forceUnwindButtonPressed(_ sender: Any) {
        forceUnwindSegue()
    }
    
    @IBAction func createLineButtonPressed(_ sender: Any) {
        if isInternetAvailable() {
            let currentUser = User.current
            let rootRef = Database.database().reference()
            let lineRef = rootRef.child("lines")
            let userRef = rootRef.child("users").child(currentUser.uid)
            if nameTextField.text == nil || nameTextField.text == "" {
                nameTextField.text = nameTextField.placeholder
            }
            let lineName: String = nameTextField.text!
            if lineName.contains(".") || lineName.contains("#") || lineName.contains("$") || lineName.contains("[") || lineName.contains("]") || lineName.contains("/") || lineName.contains("\\") {
                let _ = createErrorPopUp("Line name cannot contain the character(s) '.' '#' '$' '/' '\\' '[' or ']'.")
                return
            }
            if maxMembersTextField.text == nil || maxMembersTextField.text == "" { maxMembersTextField.text = "50" }
            guard let maxMembers: Int = Int(maxMembersTextField.text!) else {
                let _ = createErrorPopUp("Invalid input for maximum members.")
                return
            }
            var emptyCounter = 0
            if waitTimeTextFieldHours.text == nil || waitTimeTextFieldHours.text == "" { waitTimeTextFieldHours.text = "0" ; emptyCounter += 1 }
            guard let waitTimeHours: Int = Int(waitTimeTextFieldHours.text!) else {
                let _ = createErrorPopUp("Invalid input for wait time hours!")
                return
            }
            if waitTimeTextFieldSeconds.text == nil || waitTimeTextFieldSeconds.text == "" { waitTimeTextFieldSeconds.text = "0" ; emptyCounter += 1 }
            guard let waitTimeSeconds: Int = Int(waitTimeTextFieldSeconds.text!) else {
                let _ = createErrorPopUp("Invalid input for wait time seconds!")
                return
            }
            if waitTimeTextFieldMinutes.text == nil || waitTimeTextFieldMinutes.text == "" {
                waitTimeTextFieldMinutes.text = "0"
                emptyCounter += 1
            }
            guard let waitTimeMinutes: Int = Int(waitTimeTextFieldMinutes.text!) else {
                let _ = createErrorPopUp("Invalid input for wait time minutes!")
                return
            }
            if emptyCounter > 2 {
                let _ = createErrorPopUp("Please set at least 1 value for wait time!")
                waitTimeTextFieldHours.text = ""
                waitTimeTextFieldMinutes.text = ""
                waitTimeTextFieldSeconds.text = ""
                return
            } else {
                if waitTimeTextFieldHours.text == nil || waitTimeTextFieldHours.text == "" { waitTimeTextFieldHours.text = "0" }
                if waitTimeTextFieldMinutes.text == nil || waitTimeTextFieldHours.text == "" { waitTimeTextFieldHours.text = "0" }
                if waitTimeTextFieldSeconds.text == nil || waitTimeTextFieldHours.text == "" { waitTimeTextFieldHours.text = "0" }
            }
            if waitTimeHours*3600+waitTimeMinutes*60+waitTimeSeconds < 1 {
                let _ = createErrorPopUp("Cannot have wait time of 0 or less seconds!")
                return
            }
            messageTextField.text = messageTextField.text.replacingOccurrences(of: "[line name]", with: lineName)
            endLocationTextField.text = endLocationTextField.text != nil && endLocationTextField.text != "" ? endLocationTextField.text! : "(no location provided)"
            messageTextField.text = messageTextField.text.replacingOccurrences(of: "[end location]", with: endLocationTextField.text!)
            messageTextField.text = messageTextField.text.replacingOccurrences(of: "^\\n*", with: " ")
            lineRef.child(lineName).observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? [String : Any] {
                    let _ = self.createErrorPopUp("line named \(lineName) already exists!")
                    return
                } else {
                    lineRef.child(lineName).setValue(["creator": currentUser.username, "originalCreator": currentUser.uid, "maxMembers": maxMembers, "waitTime": waitTimeHours*3600+waitTimeMinutes*60+waitTimeSeconds, "endLocation": self.endLocationTextField.text!, "message": self.messageTextField.text])
                    userRef.child("hostedLines").child(lineName).setValue(true)
                    self.performSegue(withIdentifier: "manageLine", sender: self)
                }
            })
        } else {
            let _ = createErrorPopUp("No internet connection!")
        }
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
        let currentUser = User.current
        nameTextField.delegate = self
        maxMembersTextField.delegate = self
        waitTimeTextFieldHours.delegate = self
        waitTimeTextFieldMinutes.delegate = self
        waitTimeTextFieldSeconds.delegate = self
        nameTextField.placeholder = "\(currentUser.username)s Line"
        createButton.clipsToBounds = true
        createButton.layer.cornerRadius = 6
        messageTextField.layer.cornerRadius = 6
        messageView.isHidden = true
        messageView.layer.cornerRadius = 6
        messageLabel.isHidden = true
        messageLabel.layer.cornerRadius = 6
        messageTextField.delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView) {
        messageLabel.text = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        messageView.isHidden = false
        messageLabel.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        messageView.isHidden = true
        messageLabel.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if textField == nameTextField {
            return newString.length <= 32
        } else if textField == maxMembersTextField {
            return newString.length <= 8
        } else if textField == waitTimeTextFieldHours {
            return newString.length <= 7
        } else if textField == waitTimeTextFieldMinutes || textField == waitTimeTextFieldSeconds {
            return newString.length <= 2
        } else if textField == endLocationTextField {
            return newString.length <= 32
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentString: NSString = textView.text as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
        if textView == messageTextField {
            return newString.length <= 500
        }
        return true
    }
    
    func forceUnwindSegue() {
        dismiss(animated: true) {}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manageLine" {
            let controller = segue.destination as! ManageLineViewController
            controller.managedLine = self.nameTextField.text!
            controller.hidingNavBarState = true
        }
    }
}
