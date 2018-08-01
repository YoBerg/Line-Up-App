//
//  ManageMembersViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/30/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ManageMembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PopUpViewControllerListener {
    func popUpResponse(identifier: String) {
        if identifier == "kick member" {
            
            let memberRef = Database.database().reference().child("lines").child(managedLine).child("members")
            memberRef.observeSingleEvent(of: .value) { (snapshot) in
                if (snapshot.value as? [String: Int]) != nil {
                        memberRef.child(self.selectedMember!.uid).setValue(nil)
                        
                        for member in self.members {
                            if member.spot > self.selectedMember!.spot {
                                memberRef.child(member.uid).setValue(member.spot-1)
                            }
                        }
                        Database.database().reference().child("users").child(self.selectedMember!.uid).child("queuedLines").child(self.managedLine).setValue(nil)
                }
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.refreshButtonPressed(self)
            }
            manageMemberToolBar.isHidden = true
        } else if identifier == "ban member" {
            let lineRef = Database.database().reference().child("lines").child(managedLine)
            lineRef.observeSingleEvent(of: .value) { (snapshot) in
                if (snapshot.value as? [String: Any]) != nil {
                    lineRef.child("members").child(self.selectedMember!.uid).setValue(nil)
                    lineRef.child("bannedMembers").child(self.selectedMember!.uid).setValue(true)
                    
                    for member in self.members {
                        if member.spot > self.selectedMember!.spot {
                            lineRef.child("members").child(member.uid).setValue(member.spot-1)
                        }
                    }
                    Database.database().reference().child("users").child(self.selectedMember!.uid).child("queuedLines").child(self.managedLine).setValue(nil)
                }
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.refreshButtonPressed(self)
            }
            manageMemberToolBar.isHidden = true
        }
    }
    var popUpResponse: Bool = false
    var managedLine: String = ""
    var hidingNavBarState = true
    var members = [Member]() {
        didSet {
            self.membersTableView.reloadData()
        }
    }
    var selectedMember: Member?
    
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var navigationBarFromHome: UINavigationBar!
    @IBOutlet weak var manageMemberToolBar: UIToolbar!
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        members = []
        Database.database().reference().child("lines").child(managedLine).child("members").observeSingleEvent(of: .value) { (snapshot) in
            if let memberDict = snapshot.value as? [String: Int] {
                for member in memberDict {
                    self.members.append(Member(uid: member.key, spot: member.value))
                }
                self.members = self.members.sorted(by: { $0.spot < $1.spot })
            }
        }
        manageMemberToolBar.isHidden = true
    }
    
    @IBAction func kickMemberButtonPressed(_ sender: Any) {
        let _ = self.confirmAction("Confirm kicking '\(self.selectedMember!.username)' from '\(self.managedLine)'.", identifier: "kick member", sender: self)
    }
    
    @IBAction func moveMemberButtonPressed(_ sender: Any) {
    }
    
    @IBAction func banMemberButtonPressed(_ sender: Any) {
        let _ = self.confirmAction("Confirm banning '\(self.selectedMember!.username)' from '\(self.managedLine)'.", identifier: "ban member", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        membersTableView.delegate = self
        membersTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationBarFromHome.isHidden = hidingNavBarState
        self.manageMemberToolBar.isHidden = true
        refreshButtonPressed(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCell.ListMembersTableViewCell, for: indexPath) as! ListMembersTableViewCell
        
        let member = members[indexPath.row]
        Database.database().reference().child("users").child(member.uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            let username = snapshot.value as! String
            cell.memberNameLabel.text = username
            self.members[indexPath.row].username = username
        }
        cell.memberSpotLabel.text = String(member.spot + 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        manageMemberToolBar.isHidden = false
        selectedMember = members[indexPath.row]
    }
}
