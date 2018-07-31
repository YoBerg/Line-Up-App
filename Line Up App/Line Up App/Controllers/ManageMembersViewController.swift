//
//  ManageMembersViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/30/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ManageMembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var managedLine: String = ""
    var hidingNavBarState = true
    var members = [Member]() {
        didSet {
            self.membersTableView.reloadData()
        }
    }
    
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var navigationBarFromHome: UINavigationBar!
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        members = []
        Database.database().reference().child("lines").child(managedLine).child("members").observeSingleEvent(of: .value) { (snapshot) in
            if let memberDict = snapshot.value as? [String: Int] {
                for member in memberDict {
                    self.members.append(Member(uid: member.key, spot: member.value))
                }
                self.members = self.members.sorted(by: { $0.spot < $1.spot })
            } else {
                self.createErrorPopUp("Could not find line '\(self.managedLine)' in our database!")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        membersTableView.delegate = self
        membersTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationBarFromHome.isHidden = hidingNavBarState
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
        }
        cell.memberSpotLabel.text = String(member.spot)
        
        return cell
    }
}
