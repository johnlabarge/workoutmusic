//
//  WorkoutTableCell.swift
//  WorkoutMusic
//
//  Created by John La Barge on 9/14/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

import Foundation

import UIKit

class WorkoutTableCell : UITableViewCell
{

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var alignGoButton: NSLayoutConstraint!
    @IBOutlet var graph : WorkoutGraph!
    @IBOutlet var workoutName : UILabel!
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var timeLabel: TimeLabel!
    
    override func prepareForReuse() {
            
    }
}