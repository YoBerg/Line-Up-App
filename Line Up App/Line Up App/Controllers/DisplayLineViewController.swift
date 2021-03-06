//
//  DisplayLineViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/24/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DisplayLineViewController: UIViewController {
    
    var managedLine: Line?
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var interactButton: UIButton!
    @IBOutlet weak var spotNumberLabel: UILabel!
    @IBOutlet weak var endLocationLabel: UILabel!
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        dismiss(animated: true) {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func unwindWithSegue(segue: UIStoryboardSegue) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshButtonPressed(self)
    }
    
    @IBAction func interactButtonPressed(_ sender: Any) {
        if isInternetAvailable() {
        let lineRef = Database.database().reference().child("lines").child(managedLine!.name)
        let userRef = Database.database().reference().child("users").child(User.current.uid).child("queuedLines")
        
        lineRef.observeSingleEvent(of: .value) { (snapshot) in
            let lineDict = snapshot.value as! [String: Any]
            let memberDict: [String: Int] = self.isNsnullOrNil(lineDict["members"]) ? lineDict["members"] as! [String : Int] : [:]
            let memberArray: [String] = memberDict.map{$0.key}
            let bannedDict: [String: Any] = self.isNsnullOrNil(lineDict["bannedMembers"]) ? lineDict["bannedMembers"] as! [String: Any] : [:]
            let bannedArray: [String] = bannedDict.map{$0.key}
            let maxMembers: Int = lineDict["maxMembers"] as! Int
            
            if memberArray.contains(User.current.uid) {
                let userValue = memberDict[User.current.uid]
                
                for member in memberDict {
                    if member.value > userValue! {
                        lineRef.child("members").child(member.key).setValue(member.value-1)
                        Database.database().reference().child("lines").child(self.managedLine!.name).child("dummies").child(member.key).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value as? Bool != true {
                                Database.database().reference().child("users").child(member.key).child("queuedLines").child(self.managedLine!.name).setValue(member.value-1)
                            }
                        })
                    }
                }
                self.interactButton.setTitle("Take a spot", for: .normal)
                
                lineRef.child("members").child(User.current.uid).setValue(nil)
                userRef.child(self.managedLine!.name).setValue(nil)
            } else {
                if !bannedArray.contains(User.current.uid) && memberArray.count < maxMembers {
                    userRef.child(self.managedLine!.name).setValue(memberArray.count)
                    lineRef.child("members").child(User.current.uid).setValue(memberArray.count)
                    self.interactButton.setTitle("Leave line", for: .normal)
                } else if bannedArray.contains(User.current.uid) {
                    let _ = self.createErrorPopUp("You are banned from this line!")
                } else if memberArray.count >= maxMembers {
                    let _ = self.createErrorPopUp("Line is full!")
                } else {
                    let _ = self.createErrorPopUp("Could not join line for unknown reason...")
                }
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
                self.refreshButtonPressed(self)
            })
        }
        } else {
            let _ = createErrorPopUp("No internet connection!")
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        if isInternetAvailable() {
            self.interactButton.isEnabled = true
            self.interactButton.isHidden = false
            self.waitTimeLabel.isHidden = false
            self.numberOfMembersLabel.isHidden = false
            self.spotNumberLabel.isHidden = false
        let lineRef = Database.database().reference().child("lines").child(managedLine!.name)
        lineRef.observe(.value) { (snapshot) in
            
            if let lineDict = snapshot.value as? [String: Any] {
                
                //creating array of member uids from lineDict
                let memberDict: [String: Int] = lineDict["members"] != nil ? lineDict["members"] as! [String : Int] : [:]
                let memberArray: [String] = memberDict.map{$0.key}
                
                //re-assigning variables
                self.managedLine!.maxMembers = lineDict["maxMembers"] as! Int
                self.managedLine!.waitTime = lineDict["waitTime"] as! Int
                self.managedLine!.members = memberArray
                //refreshing labels
                
                self.lineNameLabel.text = self.managedLine!.name
                self.creatorNameLabel.text = "Created by \(self.managedLine!.creator)"
                self.numberOfMembersLabel.preferredMaxLayoutWidth = 300
                self.numberOfMembersLabel.text = "\(self.managedLine!.members.count) / \(self.managedLine!.maxMembers) Members"
                self.endLocationLabel.text = lineDict["endLocation"] as? String
                var selfIndex = 0
                if self.managedLine!.members.contains(User.current.uid) {
                    self.interactButton.setTitle("Leave line", for: .normal)
                    selfIndex = memberDict[User.current.uid]!+1
                    self.waitTimeLabel.preferredMaxLayoutWidth = 300
                    self.waitTimeLabel.text = "Approximately \(self.secondsToTime(self.managedLine!.waitTime * (selfIndex-1))) left."
                    self.spotNumberLabel.isHidden = false
                } else {
                    self.interactButton.setTitle("Take a spot", for: .normal)
                    self.waitTimeLabel.text = "\(self.secondsToTime(self.managedLine!.waitTime * memberDict.count)) wait time."
                    self.spotNumberLabel.isHidden = true
                }
                if memberDict.count == 1 && memberArray.contains(User.current.uid) {
                    self.spotNumberLabel.text = "You are first!"
                    self.mainView.backgroundColor = UIColor(red: CGFloat(0.6), green: CGFloat(0.9373), blue: CGFloat(0.3569), alpha: CGFloat(1))
                } else {
                    self.spotNumberLabel.text = "Spot #\(selfIndex)"
                    self.mainView.backgroundColor = UIColor(red: CGFloat(1), green: CGFloat(0.9607), blue: CGFloat(0.8471), alpha: CGFloat(1))
                }
            } else {
                let _ = self.createErrorPopUp("Line no longer exists!")
                self.dismiss(animated: true) {}
            }
        }
        } else {
            self.lineNameLabel.text = "No connection."
            self.creatorNameLabel.text = "Refresh once reconnected."
            self.interactButton.isEnabled = false
            self.interactButton.isHidden = true
            self.waitTimeLabel.isHidden = true
            self.numberOfMembersLabel.isHidden = true
            self.spotNumberLabel.isHidden = true
        }
    }
}

