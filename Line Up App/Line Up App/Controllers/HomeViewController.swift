//
//  ViewController.swift
//  Line Up App
//
//  Created by Macbook on 7/23/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

