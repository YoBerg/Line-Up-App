//
//  ViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/23/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var lines = [Line]() {
        didSet {
            self.linesTableView.reloadData()
        }
    }
    
    @IBOutlet weak var linesTableView: UITableView!
    @IBOutlet weak var searchTextField: ClosableTextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func signOutButtonTapped(_ sender: UIBarButtonItem) {
        
        //Clear UserDefault
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        //Segue back to Login storyboard
        let initialViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        searchTextField.resignFirstResponder()
        let rootRef = Database.database().reference()
        if searchTextField.text == "" || searchTextField.text == nil {
            print("searchTextField is empty!")
            return
        }
        let searchText: String! = searchTextField.text!
        let lineRef = rootRef.child("lines").child(searchText)
        
        //obtaining JSON contents of lineRef
        lineRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let lineDict = snapshot.value as? [String : Any] {
                print(lineDict.debugDescription)
                
                //using a Ternary Operator to return value of members if it isn't nil and [] if it is.
                let membersArray: [String] = lineDict["members"] != nil ? lineDict["members"] as! [String] : []
                
                self.lines = []
                self.lines.append(Line(name: lineRef.key, waitTime: lineDict["waitTime"] as! Int, members: membersArray, maxMembers: lineDict["maxMembers"] as! Int, creator: lineDict["creator"] as! String))
            } else {
                print("Did not find line in database named '\(searchText!)'")
                return
            }
        })
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
}

