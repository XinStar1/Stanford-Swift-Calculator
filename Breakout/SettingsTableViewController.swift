//
//  SettingTableViewController.swift
//  Breakout
//
//  Created by azx on 15/12/24.
//  Copyright © 2015年 azx. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITabBarControllerDelegate {
   
    //MARK: - UserDefault
    
    struct Keys {
        static let Rows = "SettingsTableViewController.numberOfRows"
        static let Balls = "SettingsTableViewController.numberOfBalls"
        static let Velocity = "SettingsTableViewController.velocity"
        static let HasGravity = "SettingsTableViewController.hasGravity"
    }
    
    // In fact, the defaults here are the same one in BreakoutViewController
    let defaults = NSUserDefaults.standardUserDefaults()
    
    //MARK: - Public API
    
    var numberOfRows: Int {
        get { return defaults.objectForKey(Keys.Rows) as? Int ?? 3}
        set { defaults.setObject(newValue, forKey: Keys.Rows) }
    }
    
    var numberOfBalls: Int {
        get { return defaults.objectForKey(Keys.Balls) as? Int ?? 1 }
        set { defaults.setObject(newValue, forKey: Keys.Balls) }
    }
    
    var velocity: CGFloat {
        get { return defaults.objectForKey(Keys.Velocity) as? CGFloat ?? 2 }
        set { defaults.setObject(newValue, forKey: Keys.Velocity) }
    }
    
    var hasGravity: Bool {
        get { return defaults.objectForKey(Keys.HasGravity) as? Bool ?? false }
        set { defaults.setObject(newValue, forKey: Keys.HasGravity) }
    }
    
    //MARK: - Slider
    
    @IBAction func moveSlider(sender: UISlider) {
        velocity = CGFloat(sender.value)
    }
    
    
    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.minimumValue = 0
            slider.maximumValue = 4
            slider.continuous = true
            slider.value = Float(velocity)
        }
        
    }
    
    //MARK: - Number of balls UI
    
    @IBOutlet weak var ballStepper: UIStepper! {
        didSet {
            ballStepper.maximumValue = 2
            ballStepper.minimumValue = 0
            ballStepper.continuous = true
            ballStepper.wraps = false
            ballStepper.stepValue = 1
            ballStepper.value = Double(numberOfBalls) - 1
        }
    }
    
    @IBOutlet weak var ballLabel: UILabel! {
        didSet { ballLabel.text = "Number of balls: \(numberOfBalls)" } // for userdefault show right number
    }
    
    @IBAction func touchBallStepper(sender: UIStepper) {
        numberOfBalls = 1 + Int(sender.value)
        ballLabel.text = "Number of balls: \(numberOfBalls)"
    }
    
    //MARK: - Number of rows UI
    
    @IBOutlet weak var rowStepper: UIStepper! {
        didSet {
            rowStepper.maximumValue = 2
            rowStepper.minimumValue = -2
            rowStepper.continuous = true
            rowStepper.wraps = false
            rowStepper.stepValue = 1
            rowStepper.value = Double(numberOfRows) - 3
        }
    }
    @IBAction func touchRowStepper(sender: UIStepper) {
        numberOfRows = 3 + Int(sender.value)
        rowLabel.text! = "Number of rows: \(numberOfRows)"
    }
    @IBOutlet weak var rowLabel: UILabel! {
        didSet { rowLabel.text = "Number of rows: \(numberOfRows)" }
    }
    
    //MARK: - Gravity switch UI
    
    @IBOutlet weak var gravitySwitch: UISwitch! {
        didSet {
            gravitySwitch.setOn(hasGravity, animated: false)
        }
    }
    
    @IBAction func touchSwitch(sender: UISwitch) {
        hasGravity = sender.on
    }
    
    //MARK: - Hide status bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - tabBarController delegate
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let breakoutController = viewController as? BreakoutViewController {
            breakoutController.brickRows = numberOfRows
            breakoutController.ballAmount = numberOfBalls
            breakoutController.breakout.magnitude = velocity
            breakoutController.breakout.hasGravity = hasGravity
        }
    }
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.delegate = self
        
        
//        defaults.registerDefaults(defaults.persistentDomainForName("com.azxccmu.Breakout")!)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
