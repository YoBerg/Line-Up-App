//
//  PopUpViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/31/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    var identifier: String = ""
    var destination: PopUpViewControllerListener?
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func yesButtonPressed(_ sender: Any) {
        destination?.popUpResponse(identifier: identifier)
        dismiss(animated: true) {}
    }
    
    @IBAction func noButtonPressed(_ sender: Any) {
        dismiss(animated: true) {}
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true) {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 15
        popUpView.layer.shadowColor = UIColor.black.cgColor
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 5)
        popUpView.layer.shadowOpacity = 0.6
        popUpView.layer.shadowRadius = 5
    }
}
