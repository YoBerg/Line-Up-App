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
    
    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var interactButton: UIButton!
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            print("returning home...")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func unwindWithSegue(segue: UIStoryboardSegue) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lineNameLabel.text = managedLine!.name
        creatorNameLabel.text = managedLine!.creator
        waitTimeLabel.text = String(managedLine!.waitTime * managedLine!.members.count)
        numberOfMembersLabel.text = "\(managedLine!.members.count) / \(managedLine!.maxMembers)"
        if managedLine!.members.contains(User.current.uid) {
            interactButton.setTitle("Leave line", for: .normal)
        } else {
            interactButton.setTitle("Take a spot", for: .normal)
        }
    }
    
    @IBAction func interactButtonPressed(_ sender: Any) {
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
                print("User is a member, leaving line.")
                let userValue = memberDict[User.current.uid]
                
                for member in memberDict {
                    if member.value > userValue! {
                        lineRef.child("members").child(member.key).setValue(member.value-1)
                    }
                }
                self.interactButton.setTitle("Take a spot", for: .normal)
                
                lineRef.child("members").child(User.current.uid).setValue(nil)
                userRef.child(self.managedLine!.name).setValue(nil)
            } else {
                print("User is not a member, joining line.")
                if !bannedArray.contains(User.current.uid) && memberArray.count < maxMembers{
                    userRef.child(self.managedLine!.name).setValue(memberArray.count)
                    lineRef.child("members").child(User.current.uid).setValue(memberArray.count)
                    self.interactButton.setTitle("Leave line", for: .normal)
                } else if bannedArray.contains(User.current.uid) {
                    self.createErrorPopUp("You are banned from this line!")
                } else if memberArray.count >= maxMembers {
                    self.createErrorPopUp("Line is full!")
                } else {
                    self.createErrorPopUp("Could not join line for unknown reason...")
                }
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
                self.refreshButtonPressed(self)
            })
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        
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
            } else {
                self.createErrorPopUp("Line no longer exists!")
                self.dismiss(animated: true, completion: {
                    print("returning home...")
                })
            }
        }
        //refreshing labels
        
        lineNameLabel.text = managedLine!.name
        creatorNameLabel.text = managedLine!.creator
        waitTimeLabel.text = String(managedLine!.waitTime * managedLine!.members.count)
        numberOfMembersLabel.text = "\(managedLine!.members.count) / \(managedLine!.maxMembers)"
        if managedLine!.members.contains(User.current.uid) {
            interactButton.setTitle("Leave line", for: .normal)
        } else {
            interactButton.setTitle("Take a spot", for: .normal)
        }
    }
}
