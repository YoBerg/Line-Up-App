//
//  ManageLineViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/24/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ManageLineViewController: UIViewController, PopUpViewControllerListener {
    
    var popUpInput: String?
    var managedLine: String?
    var hidingNavBarState: Bool = true
    
    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var navigationBarFromHome: UINavigationBar!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var editLineButton: UIButton!
    @IBOutlet weak var manageMembersButton: UIButton!
    @IBOutlet weak var deleteLineButton: UIButton!
    
    @IBOutlet weak var editLineView: UIView!
    @IBOutlet weak var changeMaxMembersTextField: ClosableTextField!
    @IBOutlet weak var changeMaxMembersButton: UIButton!
    @IBOutlet weak var changeWaitTimeTextField: ClosableTextField!
    @IBOutlet weak var changeWaitTimeButton: UIButton!
    @IBOutlet weak var changeOwnerTextField: ClosableTextField!
    @IBOutlet weak var changeOwnerButton: UIButton!
    @IBOutlet weak var exitEditLineViewButton: UIButton!
    
    @IBAction func changeMaxMembersButtonPressed(_ sender: Any) {
        let _ = confirmAction("About to change maximum members. Confirm? (Existing members will not be kicked.)", identifier: "change max members", sender: self)
    }
    
    @IBAction func changeWaitTimeButtonPressed(_ sender: Any) {
        let _ = confirmAction("About to change wait time. Confirm?", identifier: "change wait time", sender: self)
    }
    
    @IBAction func changeOwnerButtonPressed(_ sender: Any) {
        let _ = confirmAction("About to change owner of this line. Confirm? (This action cannot be undone. The original creator is recorded.)", identifier: "change owner", sender: self)
    }
    
    @IBAction func exitEditLineViewButton(_ sender: Any) {
        editLineView.isHidden = true
        changeMaxMembersTextField.isHidden = true
        changeMaxMembersButton.isHidden = true
        changeWaitTimeTextField.isHidden = true
        changeWaitTimeButton.isHidden = true
        changeOwnerTextField.isHidden = true
        changeOwnerButton.isHidden = true
        exitEditLineViewButton.isHidden = true
        changeMaxMembersTextField.isEnabled = false
        changeMaxMembersButton.isEnabled = false
        changeWaitTimeTextField.isEnabled = false
        changeWaitTimeButton.isEnabled = false
        changeOwnerTextField.isEnabled = false
        changeOwnerButton.isEnabled = false
        exitEditLineViewButton.isEnabled = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if textField == changeMaxMembersTextField {
            return newString.length <= 8
        } else if textField == changeWaitTimeTextField {
            return newString.length <= 2
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 6
        nextButton.clipsToBounds = true
        editLineButton.layer.cornerRadius = 6
        editLineButton.clipsToBounds = true
        manageMembersButton.layer.cornerRadius = 6
        manageMembersButton.clipsToBounds = true
        deleteLineButton.layer.cornerRadius = 6
        deleteLineButton.clipsToBounds = true
        editLineView.layer.cornerRadius = 10
        editLineView.clipsToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        if isInternetAvailable() {
        let lineRef = Database.database().reference().child("lines").child(managedLine!)
        lineRef.observeSingleEvent(of: .value) { (snapshot) in
            let lineDict = snapshot.value as! [String : Any]
            self.waitTimeLabel.text = "\(self.secondsToTime(lineDict["waitTime"] as! Int)) / spot"
            let members = lineDict["members"] as? [String: Int]
            let lineDictMembers = members != nil || members?.count == 0 ? Array(members!.keys) : []
            let numberOfMembers: Int = lineDictMembers.count
            self.numberOfMembersLabel.text = "\(numberOfMembers) / \(lineDict["maxMembers"] ?? 0) Members"
        }
            self.lineNameLabel.text = managedLine!
        } else {
            lineNameLabel.text = "No connection."
            numberOfMembersLabel.text = "Refresh once reconnected."
            waitTimeLabel.isHidden = true
        }
        self.navigationBarFromHome.isHidden = hidingNavBarState
    }
    
    @IBAction func unwindWithSegue(segue: UIStoryboardSegue) {
    }
    @IBAction func hidingHomeButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            print("returning home...")
        }
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindWithSegue", sender: self)
    }
    
    @IBAction func editLineButtonPressed(_ sender: Any) {
        editLineView.isHidden = false
        changeMaxMembersTextField.isHidden = false
        changeMaxMembersButton.isHidden = false
        changeWaitTimeTextField.isHidden = false
        changeWaitTimeButton.isHidden = false
        changeOwnerTextField.isHidden = false
        changeOwnerButton.isHidden = false
        exitEditLineViewButton.isHidden = false
        changeMaxMembersTextField.isEnabled = true
        changeMaxMembersButton.isEnabled = true
        changeWaitTimeTextField.isEnabled = true
        changeWaitTimeButton.isEnabled = true
        changeOwnerTextField.isEnabled = true
        changeOwnerButton.isEnabled = true
        exitEditLineViewButton.isEnabled = true
    }
    
    @IBAction func deleteLineButtonPressed(_ sender: Any) {
        if isInternetAvailable() {
            let _ = confirmAction("Delete line \(managedLine!)?", identifier: "delete line", sender: self)
        } else {
            let _ = createErrorPopUp("No internet connection!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindWithSegue" {
            let createLineViewController = segue.destination as! CreateLineViewController
            createLineViewController.forceUnwindSegue()
        } else if segue.identifier == "manageMembers" {
            let manageMembersViewController = segue.destination as! ManageMembersViewController
            manageMembersViewController.hidingNavBarState = hidingNavBarState
            manageMembersViewController.managedLine = managedLine!
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        nextButton.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
            self.nextButton.isEnabled = true
        }
        if isInternetAvailable() {
            let memberRef = Database.database().reference().child("lines").child(managedLine!).child("members")
            memberRef.observeSingleEvent(of: .value) { (snapshot) in
                if let memberDict = snapshot.value as?[String: Int] {
                    for member in memberDict {
                        if member.value == 0 {
                            memberRef.child(member.key).setValue(nil)
                            Database.database().reference().child("users").child(member.key).child("queuedLines").child(self.managedLine!).setValue(nil)
                        } else {
                            memberRef.child(member.key).setValue(member.value - 1)
                            Database.database().reference().child("lines").child(self.managedLine!).child("dummies").child(member.key).observeSingleEvent(of: .value, with: { (snapshot) in
                                if snapshot.value as? Bool != true {
                                    Database.database().reference().child("users").child(member.key).child("queuedLines").child(self.managedLine!).setValue(member.value - 1)
                                }
                            })
                        }
                    }
                } else {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
                        let _ = self.createErrorPopUp("No members in line!")
                    })
                }
            }
            refreshButtonPressed(self)
        } else {
            let _ = self.createErrorPopUp("No internet connection!")
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        if isInternetAvailable() {
            waitTimeLabel.isHidden = false
        let lineRef = Database.database().reference().child("lines").child(managedLine!)
        lineRef.observe(.value) { (snapshot) in
            if let lineDict = snapshot.value as? [String : Any] {
                let membersFromDict = lineDict["members"] as? [String: Int]
                let members: [String: Int] = membersFromDict != nil ? membersFromDict! : [:]
                let waitTime = lineDict["waitTime"] as! Int
                let maxMembers = lineDict["maxMembers"] as! Int
                self.numberOfMembersLabel.preferredMaxLayoutWidth = 300
                self.numberOfMembersLabel.text = "\(members.count) / \(maxMembers) Members"
                self.waitTimeLabel.preferredMaxLayoutWidth = 300
                self.waitTimeLabel.text = "\(self.secondsToTime(waitTime)) / spot."
            } else {
                let _ = self.createErrorPopUp("Line no longer exists!")
                self.performSegue(withIdentifier: "unwindWithSegue", sender: self)
                self.dismiss(animated: true) {
                    print("returning home...")
                }
            }
        }
        }
    }
    
    func popUpResponse(identifier: String) {
        if isInternetAvailable() {
            if identifier == "delete line" {
                Database.database().reference().child("lines").child(managedLine!).setValue(nil)
                Database.database().reference().child("users").child(User.current.uid).child("hostedLines").child(managedLine!).setValue(nil)
                self.performSegue(withIdentifier: "unwindWithSegue", sender: self)
                dismiss(animated: true) {
                    print("returning home...")
                }
            }
            else if identifier == "change max members" {
                let lineRef = Database.database().reference().child("lines").child(managedLine!)
                if let newMaxMembers = Int(changeMaxMembersTextField.text!) {
                    if newMaxMembers < 1 {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                            let _ = self.createErrorPopUp("Cannot set maximum members to less than 1")
                        }
                        return
                    }
                    lineRef.child("maxMembers").setValue(newMaxMembers)
                    refreshButtonPressed(self)
                } else {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Did not enter valid input into respective text field!")
                    }
                }
            }
            else if identifier == "change wait time" {
                let lineRef = Database.database().reference().child("lines").child(managedLine!)
                var newWaitTimeText = changeWaitTimeTextField.text != nil ? changeWaitTimeTextField.text! : ""
                newWaitTimeText = newWaitTimeText.replacingOccurrences(of: ",", with: "")
                var colonOccurences = 0
                for char in newWaitTimeText {
                    colonOccurences += char == ":" ? 1 : 0
                }
                if colonOccurences != 2 {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Did not enter time in correct format. Try Hrs:Mins:Secs")
                    }
                    return
                }
                let waitTimeArray = newWaitTimeText.split(separator: ":")
                if waitTimeArray.count != 3 {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Bad input! Is one of the fields empty?")
                    }
                    return
                }
                guard let hours = Int(waitTimeArray[0]) else {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Could not convert \(waitTimeArray[0]) into a number. Make sure you only used numbers")
                    }
                    return
                }
                guard let minutes = Int(waitTimeArray[1]) else {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Could not convert \(waitTimeArray[1]) into a number. Make sure you only used numbers")
                    }
                    return
                }
                guard let seconds = Int(waitTimeArray[2]) else {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Could not convert \(waitTimeArray[2]) into a number. Make sure you only used numbers")
                    }
                    return
                }
                if hours > 9999999 {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Value for hours is too large! Do not exceed 9,999,999")
                    }
                    return
                } else if minutes > 59 {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Value for minutes is too large! Do not exceed 59")
                    }
                    return
                } else if seconds > 59 {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                        let _ = self.createErrorPopUp("Value for seconds is too large! Do not exceed 59")
                    }
                    return
                }
                let newWaitTime = seconds+(minutes*60)+(hours*3600)
                lineRef.child("waitTime").setValue(newWaitTime)
                self.refreshButtonPressed(self)
            }
            else if identifier == "change owner" {
                let lineRef = Database.database().reference().child("lines").child(managedLine!)
                let userRef = Database.database().reference().child("users")
                userRef.observeSingleEvent(of: .value) { (snapshot) in
                    let usersDict = snapshot.value as! [String: Any]
                    for user in usersDict {
                        if self.changeOwnerTextField.text == nil || self.changeOwnerTextField.text == "" {
                            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
                                let _ = self.createErrorPopUp("Did not enter valid input into respective text field!")
                            })
                            break
                        }
                        let userDict = user.value as! [String: Any]
                        if userDict["username"] as! String == self.changeOwnerTextField.text! {
                            lineRef.child("creator").setValue(self.changeOwnerTextField.text!)
                            userRef.child(user.key).child("hostedLines").child(self.managedLine!).setValue(true)
                            userRef.child(User.current.uid).child("hostedLines").child(self.managedLine!).setValue(nil)
                            self.dismiss(animated: true) {}
                        }
                    }
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
                        let _ = self.createErrorPopUp("Did not find user \(self.changeOwnerTextField.text!)")
                    })
                }
            }
        } else {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                let _ = self.createErrorPopUp("No internet connection!")
            }
        }
    }
}
