//
//  TransitionToEditSegue.swift
//  WorkoutMusic
//
//  Created by John La Barge on 10/7/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

import Foundation
import UIKit

class TransitionToEditSegue : UIStoryboardSegue
{
    override func perform() {
        let workoutVC: WorkoutViewController = self.sourceViewController as! WorkoutViewController
        let workout:Workout = workoutVC.workout
        
        let workoutDesignerVC : WorkoutDesignerVC = self.destinationViewController as! WorkoutDesignerVC
        workoutDesignerVC.model = workout
        
        if let navController = self.sourceViewController.navigationController {
            navController?.popToRootViewControllerAnimated(true);
            navController?.pushViewController(workoutDesignerVC, animated: true)
        }
    }
}
