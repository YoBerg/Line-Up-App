//
//  createUsernameViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/24/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class createUsernameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: ClosableTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        nextButton.layer.cornerRadius = 8
        nextButton.clipsToBounds = true
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if isInternetAvailable() {
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
            if username.contains("/") || username.contains("$") || username.contains("\\") || username.contains("#") || username.contains("[") || username.contains("]") || username.contains(".") {
                let _ = createErrorPopUp("username must not contain the following: # $ / \\ [ ] .")
            }
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else {
                // handle error
                return
            }
            
            User.setCurrent(user, writeToUserDefaults: true)
            
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
        } else {
            let _ = createErrorPopUp("No internet connection!")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= 12
    }
}
