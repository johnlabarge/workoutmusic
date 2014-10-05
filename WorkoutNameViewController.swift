//
//  WorkoutNameViewController.swift
//  WorkoutMusic
//
//  Created by John La Barge on 9/15/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

import Foundation
import UIKit

class WorkoutNameViewController : UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var workoutNameField: UITextField!
    
    @IBOutlet weak var createWorkoutButton: UIButton!
    
    var workout : Workout!
    
    
    func textFieldDidEndEditing(textField: UITextField) {
            self.workout.name = textField.text
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.workout.name = textField.text
        self.performSegueWithIdentifier("editNewWorkout", sender: self);
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        self.workoutNameField.becomeFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editNewWorkout") {
            let designer: WorkoutDesignerVC = segue.destinationViewController as WorkoutDesignerVC
            workout.name = workoutNameField.text
            designer.model = workout
        }
    }

}
