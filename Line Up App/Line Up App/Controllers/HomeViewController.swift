//
//  ViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/23/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, PopUpViewControllerListener {
    
    var lines = [Line]() {
        didSet {
            self.linesTableView.reloadData()
        }
    }
    var lineNameToDeliver: String?
    var lineClassToDeliver: Line?
    @IBOutlet weak var linesTableView: UITableView!
    @IBOutlet weak var searchTextField: ClosableTextField!
    @IBOutlet weak var searchButton: UIButton!

    @IBAction func signOutButtonTapped(_ sender: UIBarButtonItem) {
        let _ = confirmAction("Are you sure you want to sign out?", identifier: "sign out", sender: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if textField == searchTextField {
            return newString.length <= 20
        }
        return true
    }
    
    func popUpResponse(identifier: String) {
        if identifier == "sign out" {
            //Clear UserDefault
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            
            //Segue back to Login storyboard
            let initialViewController = UIStoryboard.initialViewController(for: .login)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        searchTextField.resignFirstResponder()
        let rootRef = Database.database().reference()
        if searchTextField.text == "" || searchTextField.text == nil {
            let _ = createErrorPopUp("Your query is empty!")
            return
        }
        let searchText: String = searchTextField.text!
        let lineRef = rootRef.child("lines")
        
        //obtaining JSON contents of lineRef
        lineRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let linesDict = snapshot.value as? [String : Any] {
                self.lines = []
                for line in linesDict {
                    let lineDict = line.value as! [String: Any]
                    let result = line.key.lowercased().index(of: searchText.lowercased())?.encodedOffset
                    if result != nil {
                        let memberDict: [String: Int] = self.isNsnullOrNil(lineDict["members"]) ? lineDict["members"] as! [String: Int] : [:]
                        let memberArray: [String] = memberDict.map{$0.key}
                        self.lines.append(Line(name: line.key, waitTime: lineDict["waitTime"] as! Int, members: memberArray, maxMembers: lineDict["maxMembers"] as! Int, creator: lineDict["creator"] as! String))
                    }
                }
            } else {
                let _ = self.createErrorPopUp("Our database appears to be empty!")
            }
        })
    }
    
    @IBAction func findUserHostedLinesButtonPressed(_ sender: Any) {
        let currentUser = User.current
        let rootRef = Database.database().reference()
        let linesRef = rootRef.child("lines")
        let userRef = rootRef.child("users").child(currentUser.uid)
        self.lines = []
        // 1
        userRef.child("hostedLines").observeSingleEvent(of: .value, with: { (snapshotA) in
            // 2
            if let hostedLinesDict = snapshotA.value as? [String : Any] {
                // 3
                for lineName in hostedLinesDict {
                    // 4
                    linesRef.child(lineName.key).observeSingleEvent(of: .value, with: { (snapshotB) in
                        // 5
                        if let lineDict = snapshotB.value as? [String : Any] {
                            // 6
                            let members = lineDict["members"] as? [String: Int]
                            let membersArray: [String] = members != nil ? Array(members!.keys) : []
                            self.lines.append(Line(name: lineName.key, waitTime: lineDict["waitTime"] as! Int, members: membersArray, maxMembers: lineDict["maxMembers"] as! Int, creator: lineDict["creator"] as! String))
                        }
                    })
                }
            }
        })
        /*
         1: created a snapshot containing the hosted line names JSON from the Firebase database.
         2: created a dict from the JSON we pulled from the Firebase database.
         3: cycling through every lineName owned by the user.
         4: created another snapshot containing the lines that match the hosted line names JSON from the Firebase Database.
         5: created a dict from the JSON we pulled from the Firebase database.
         6: populated the lines array with the information we have from the dict.
         */
    }
    
    @IBAction func findUserQueuedLinesButtonPressed(_ sender: Any) {
        let currentUser = User.current
        let rootRef = Database.database().reference()
        let linesRef = rootRef.child("lines")
        let userRef = rootRef.child("users").child(currentUser.uid)
        self.lines = []
        // 1
        userRef.child("queuedLines").observeSingleEvent(of: .value, with: { (snapshotA) in
            // 2
            if let queuedLineDict = snapshotA.value as? [String : Any] {
                // 3
                for lineName in queuedLineDict {
                    // 4
                    linesRef.child(lineName.key).observeSingleEvent(of: .value, with: { (snapshotB) in
                        // 5
                        if let lineDict = snapshotB.value as? [String : Any] {
                            // 6
                            let members = lineDict["members"] as? [String: Int]
                            let membersArray: [String] = members != nil ? Array(members!.keys) : []
                            self.lines.append(Line(name: lineName.key, waitTime: lineDict["waitTime"] as! Int, members: membersArray, maxMembers: lineDict["maxMembers"] as! Int, creator: lineDict["creator"] as! String))
                        }
                    })
                }
            }
        })
        /*
         1: created a snapshot containing the hosted line names JSON from the Firebase database.
         2: created a dict from the JSON we pulled from the Firebase database.
         3: cycling through every lineName owned by the user.
         4: created another snapshot containing the lines that match the hosted line names JSON from the Firebase Database.
         5: created a dict from the JSON we pulled from the Firebase database.
         6: populated the lines array with the information we have from the dict.
         */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linesTableView.delegate = self
        linesTableView.dataSource = self
        searchTextField.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return lines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCell.ListLinesTableViewCell, for: indexPath) as! ListLinesTableViewCell

        let line = lines[indexPath.row]
        cell.LineNameLabel.text = line.name
        cell.LineCreatorLabel.text = "by " + line.creator
        cell.WaitTimeLabel.text = String(line.waitTime*line.members.count)+"s"
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchButtonPressed(self)
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLine = lines[indexPath.row]
        if selectedLine.creator == User.current.username {
            print("Manage Line \(selectedLine.name)")
            lineNameToDeliver = selectedLine.name
            self.performSegue(withIdentifier: "manageLine", sender: self)
        } else {
            lineClassToDeliver = selectedLine
            self.performSegue(withIdentifier: "viewLine", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manageLine" {
            let controller = segue.destination as! ManageLineViewController
            controller.managedLine = lineNameToDeliver!
            controller.hidingNavBarState = false
        }
        if segue.identifier == "viewLine" {
            let controller = segue.destination as! DisplayLineViewController
            controller.managedLine = lineClassToDeliver!
        }
    }
}

