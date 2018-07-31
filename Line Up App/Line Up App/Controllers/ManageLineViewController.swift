//
//  ManageLineViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/24/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ManageLineViewController: UIViewController {
    
    var managedLine: String?
    var hidingNavBarState: Bool = true
    
    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var navigationBarFromHome: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let lineRef = Database.database().reference().child("lines").child(managedLine!)
        lineRef.observeSingleEvent(of: .value) { (snapshot) in
            let lineDict = snapshot.value as! [String : Any]
            self.waitTimeLabel.text = String(lineDict["waitTime"] as! Int)
            let members = lineDict["members"] as? [String: Int]
            let lineDictMembers = members != nil || members?.count == 0 ? Array(members!.keys) : []
            let numberOfMembers: Int = lineDictMembers.count
            self.numberOfMembersLabel.text = "\(numberOfMembers) / \(lineDict["maxMembers"] ?? 0)"
        }
        self.lineNameLabel.text = managedLine!
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
    
    @IBAction func deleteLineButtonPressed(_ sender: Any) {
        createErrorPopUp("Deleting line \(managedLine!)")
        Database.database().reference().child("lines").child(managedLine!).setValue(nil)
        Database.database().reference().child("users").child(User.current.uid).child("hostedLines").child(managedLine!).setValue(nil)
        self.performSegue(withIdentifier: "unwindWithSegue", sender: self)
        dismiss(animated: true) {
            print("returning home...")
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
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        let lineRef = Database.database().reference().child("lines").child(managedLine!)
        lineRef.observe(.value) { (snapshot) in
            if let lineDict = snapshot.value as? [String : Any] {
                let membersFromDict = lineDict["members"] as? [String: Int]
                let members: [String: Int] = membersFromDict != nil ? membersFromDict! : [:]
                let waitTime = lineDict["waitTime"] as! Int
                let maxMembers = lineDict["maxMembers"] as! Int
                self.numberOfMembersLabel.text = "\(members.count) / \(maxMembers)"
                self.waitTimeLabel.text = String(waitTime * members.count)
            } else {
                self.createErrorPopUp("Line no longer exists!")
                self.performSegue(withIdentifier: "unwindWithSegue", sender: self)
                self.dismiss(animated: true) {
                    print("returning home...")
                }
            }
        }
    }
}
