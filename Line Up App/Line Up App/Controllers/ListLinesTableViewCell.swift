//
//  ListLinesTableViewCell.swift
//  Line Up App
//
//  Created by Macbook on 7/24/18.
//  Copyright © 2018 Yohan Berg. All rights reserved.
//

import UIKit

class ListLinesTableViewCell: UITableViewCell {
    
    var delegate: flagButtonDelegate!
    var indexPath: IndexPath!
    
    @IBOutlet weak var LineNameLabel: UILabel!
    @IBOutlet weak var WaitTimeLabel: UILabel!
    @IBOutlet weak var LineCreatorLabel: UILabel!
    @IBAction func flagButtonPressed(_ sender: Any) {
        self.delegate?.flagButtonPressed(index: indexPath)
    }    
}

protocol flagButtonDelegate {
    func flagButtonPressed(index: IndexPath)
}
