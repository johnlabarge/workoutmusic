//
//  WorkoutListViewController.swift
//  WorkoutMusic
//
//  Created by John La Barge on 9/14/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

import Foundation
import UIKit


class WorkoutListViewController :  UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }
    
    @IBAction func doWorkout(sender: AnyObject) {
        
        let workout = selectedWorkout()
        if ((workout) != nil) {
            performSegueWithIdentifier("doWorkout", sender: self)
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let workoutCell : WorkoutTableCell = tableView.dequeueReusableCellWithIdentifier("workoutCell", forIndexPath:indexPath ) as WorkoutTableCell
        let workout : Workout = Workouts.list()[indexPath.row] as Workout
        workoutCell.graph.workout = workout
        workoutCell.workoutName.text = workout.name!
        workoutCell.timeLabel.seconds = workout.workoutSeconds
        return workoutCell
    
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Workouts.list().count;
    }
    
 
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 100.0;
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "doWorkout") {
                let workout_player :WorkoutViewController = segue.destinationViewController as WorkoutViewController
                workout_player.workout = selectedWorkout()!

        } else if (segue.identifier == "editWorkout") {
            let designer : WorkoutDesignerVC = segue.destinationViewController as WorkoutDesignerVC
                designer.model = selectedWorkout()!
        } else if (segue.identifier == "newWorkout") {
            let namer : WorkoutNameViewController = segue.destinationViewController as WorkoutNameViewController
            namer.workout = Workout()
        }
        
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var should = true
        println("Trying to segue to \(identifier) ")
        if (identifier == "editWorkout" || identifier == "doWorkout") {
            let workout : Workout? = selectedWorkout()
            should = (workout != nil)
        }
        return should 
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
 
        
       
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: WorkoutTableCell = tableView.cellForRowAtIndexPath(indexPath) as WorkoutTableCell
        var delay : dispatch_time_t = NSEC_PER_SEC*6
        dispatch_after(
            delay,
            dispatch_get_main_queue()) { () -> Void in
                self.performSegueWithIdentifier("doWorkout", sender: self)
            }
    }
    
    func selectedWorkout_() -> Workout
    {
        return selectedWorkout()!
    }
    func selectedWorkout() -> Workout?
    {
        var workout : Workout?
        if let index = tableView.indexPathForSelectedRow() {
            workout = Workouts.list()[index.row] as? Workout
        }
        return workout
        
    }
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData();
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
       var editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title:"Edit", { (action, indexPath) -> Void in
            println("edit workout at row: \(indexPath.row)")
            self.tableView.selectRowAtIndexPath(indexPath,animated: false, scrollPosition: UITableViewScrollPosition.None)
            self.performSegueWithIdentifier("editWorkout", sender: self);
        })
        editAction.backgroundColor = UIColor(red: 58/255.0, green: 169/255.0, blue: 242/255.0, alpha: 1.0)
        return [editAction,
            
            UITableViewRowAction(style: UITableViewRowActionStyle.Default, title:"Delete",{ (action, indexPath ) -> Void in
                println("delete workout at row : \(indexPath.row)")
                self.tableView.selectRowAtIndexPath(indexPath,animated: false, scrollPosition: UITableViewScrollPosition.None)
                var alerter: UIAlertController = UIAlertController(title:"Delete Workout?", message: "Delete this workout forever?", preferredStyle: UIAlertControllerStyle.Alert)
                alerter.addAction(UIAlertAction(title:"No!", style: UIAlertActionStyle.Default, handler: nil))
                alerter.addAction(UIAlertAction(title: "Yes, get rid of it!", style: UIAlertActionStyle.Destructive, handler: { (alertAction) -> Void in
                     self.selectedWorkout()!.destroy()
                    self.tableView.reloadData()
                }))
                self.presentViewController(alerter,animated: true, completion:nil)
                
            })]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // noop Apple bug requires this method to be here
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    func buttonPanelView() -> UIView? {
        let view:UIView = UIView()
        view.backgroundColor = UIColor.blackColor()
        
        
        let goButton: UIButton = view.add(UIButton()) as UIButton
        goButton.setTitle("Go", forState: UIControlState.Normal)
        view.layoutView(goButton, atWidthProportion: 1.0/2.0)
        view.layoutView(goButton, atHeightProportion: 1.0)
        goButton.backgroundColor = UIColor.greenColor();
        view.layoutView(goButton, leading:0.0)
        
        let editButton: UIButton = view.add(UIButton()) as UIButton
        editButton.setTitle("Edit", forState: UIControlState.Normal)
        view.layoutView(editButton,atWidthProportion: 1.0/3.0);
        view.trailingSpaceFrom(goButton, toView: editButton, equals: 0.0); 
        
        let deleteButton: UIButton = view.add(UIButton()) as UIButton
        deleteButton.setTitle("Delete", forState: UIControlState.Normal)
        view.layoutView(deleteButton, atWidthProportion: 1.0/3.0)
        view.layoutView(deleteButton, trailing: 0.0)
        
        return view;
    }
}