//
//  LoginViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/24/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase

typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if isInternetAvailable() {
        // 1
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        // 2
        authUI.delegate = self
        
        // 3
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
        } else {
            let _ = createErrorPopUp("No internet connection!")
        }
    }
}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            if isInternetAvailable() {
                let _ = createErrorPopUp("Could not sign in! \(error.localizedDescription)")
                print(error.localizedDescription)
            } else {
                let _ = createErrorPopUp("No internet connection!")
            }
            return
        }
        
        // 1
        guard let user = authDataResult?.user
            else { return }
        
        // 2
        let userRef = Database.database().reference().child("users").child(user.uid)
        
        // 3
        userRef.observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
            if let user = User(snapshot: snapshot) {
                User.setCurrent(user, writeToUserDefaults: true)
                print("attempting to push token to database")
                if let notif_token = Constants.Tokens.deviceToken {
                    print("pushing token \(notif_token)")
                    Database.database().reference().child("users").child(User.current.uid).child("notification_tokens").child(notif_token).setValue(true)
                }
                
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
            } else {
                self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
            }
        })
    }
}


