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
        if managedLine!.members.contains(User.current.uid) {
            Database.database().reference().child("lines").child(managedLine!.name).child("members").child(User.current.uid).setValue(nil)
            interactButton.setTitle("Take a spot", for: .normal)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.refreshButtonPressed(self)
            }
        } else {
            refreshButtonPressed(self)
            if managedLine!.members.count >= managedLine!.maxMembers {
                createErrorPopUp("Line is full!")
                return
            }
            Database.database().reference().child("lines").child(managedLine!.name).child("members").child(User.current.uid).setValue(true)
            interactButton.setTitle("Leave line", for: .normal)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.refreshButtonPressed(self)
            }
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        let lineRef = Database.database().reference().child("lines").child(managedLine!.name)
        lineRef.observe(.value) { (snapshot) in
            if let lineDict = snapshot.value as? [String : Any] {
                let members = lineDict["members"] as? [String: Bool]
                self.managedLine!.members = members != nil ? Array(members!.keys) : []
            } else {
                self.createErrorPopUp("Line no longer exists!")
                self.dismiss(animated: true, completion: {
                    print("returning home...")
                })
            }
        }
        numberOfMembersLabel.text = "\(managedLine!.members.count) / \(managedLine!.maxMembers)"
        waitTimeLabel.text = String(managedLine!.waitTime * managedLine!.members.count)
    }
}
