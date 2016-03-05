//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by azx on 15/12/24.
//  Copyright © 2015年 azx. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {

    //MARK: - User default
    
    // In fact, the defaults here are the same one in SettingsTableViewController
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    struct Keys {
        static let Rows = "BreakoutViewController.brickRows"
        static let Balls = "BreakoutViewController.ballAmount"
    }
    
    
    //MARK: - Gesture
    
    @IBOutlet var pan: UIPanGestureRecognizer! {
        didSet {
            pan.addTarget(self, action: "pinScreen:")
        }
    }
    
    @IBOutlet var tap: UITapGestureRecognizer! {
        didSet {
            tap.addTarget(self, action: "tapScreen:")
        }
    }
    
    func tapScreen(gesture: UITapGestureRecognizer) {
        switch ballAmount {
        case 1:
            if gesture.state == .Ended {
                breakout.pushBall(ball1!)
            }
        case 2:
            if gesture.state == .Ended {
                breakout.pushBall(ball1!)
                breakout.pushBall(ball2!)
            }
        case 3:
            if gesture.state == .Ended {
                breakout.pushBall(ball1!)
                breakout.pushBall(ball2!)
                breakout.pushBall(ball3!)
            }
        default: break
        }
    }
    
    func pinScreen(gesture: UIPanGestureRecognizer) {
        if gesture.state == .Changed {
            paddle?.frame.origin.x += gesture.translationInView(boundView).x
            gesture.setTranslation(CGPointZero, inView: boundView)
            breakout.addPaddleBounds(paddle!)
        }
    }
    
    //MARK: - animator and breakout behavior
    
    @IBOutlet weak var boundView: UIView!
    
    lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self.boundView) }()
    
    var breakout = BreakoutBehavior()
    
    //MARK: - Collision behavior delegate ---  detect when contacted
    
    var count: Int = 0
    var score: Int = 0 {
        didSet { label.text = "Score: \(score)" }
    }
    var bonus: Int = 0
    var isContinuous: Bool = true
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        if let id = identifier as? String { print("\(id.substringToIndex(id.characters.indexOf("d")!))")
            if id.substringToIndex(id.characters.indexOf("d")!) == "Brick Boun" {
                if let brick = boundView.viewWithTag(Int(id.substringFromIndex(id.characters.indexOf("d")!.advancedBy(1)))!) {
                    UIView.transitionWithView(brick, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                        brick.alpha = 0
                        behavior.removeBoundaryWithIdentifier(id)
                        }, completion: { (Bool finished) -> Void in
                            brick.removeFromSuperview()
                    })
                    count++
                    
                    bonus++
                    score += bonus
                    
                    if count >= brickRows * 5 { gameover() }
                }
            } else if id.substringToIndex(id.characters.indexOf("d")!) == "Bottom Boun" {
                gameover()
            } else if id.substringToIndex(id.characters.indexOf("d")!) == "Pa" {
                bonus = 0
            }
        }
    }
    
    //MARK: - Add balls and paddle
    
    var ball1: UIView?
    var ball2: UIView?
    var ball3: UIView?
    
    var paddle: UIView?
    
    var ballAmount: Int {
        get { return defaults.objectForKey(Keys.Balls) as? Int ?? 1 }
        set { defaults.setObject(newValue, forKey: Keys.Balls) }
    }
    
    func addPaddleAndBall() {
        let boundWidth = boundView.frame.size.width
        let paddleWidth = boundWidth / 6
        let boundMaxY = boundView.frame.maxY
        let paddleHeight = paddleWidth / 5
        
        paddle = UIView(frame: CGRect(x: boundWidth/2-paddleWidth/2, y: boundMaxY - paddleHeight, width: paddleWidth, height: paddleHeight))
        
        paddle!.backgroundColor = UIColor.blueColor()
        
        boundView.addSubview(paddle!)
        
        let ballWidth = paddleHeight * 1.5
        let ballHeight = ballWidth
        let ballY = boundMaxY - paddleHeight - ballHeight
        
        switch ballAmount {  // ballWidth == 0.3 * paddleWidth
        case 1:
            ball1 = UIView(frame: CGRect(x: boundWidth/2-ballWidth/2, y: ballY, width: ballWidth, height: ballHeight))
            
            ball1!.backgroundColor = UIColor.redColor()
            boundView.addSubview(ball1!)
        case 2:
            ball1 = UIView(frame: CGRect(x: boundWidth/2-paddleWidth*0.35, y: ballY, width: ballWidth, height: ballHeight))
            ball2 = UIView(frame: CGRect(x: boundWidth/2+paddleWidth*0.05, y: ballY, width: ballWidth, height: ballHeight))
            
            ball1!.backgroundColor = UIColor.redColor()
            ball2!.backgroundColor = UIColor.redColor()
            boundView.addSubview(ball1!)
            boundView.addSubview(ball2!)
        case 3:
            ball1 = UIView(frame: CGRect(x: boundWidth/2-paddleWidth*0.475, y: ballY, width: ballWidth, height: ballHeight))
            ball2 = UIView(frame: CGRect(x: boundWidth/2-paddleWidth*0.15, y: ballY, width: ballWidth, height: ballHeight))
            ball3 = UIView(frame: CGRect(x: boundWidth/2+paddleWidth*0.175, y: ballY, width: ballWidth, height: ballHeight))
            
            ball1!.backgroundColor = UIColor.redColor()
            ball2!.backgroundColor = UIColor.redColor()
            ball3!.backgroundColor = UIColor.redColor()
            boundView.addSubview(ball1!)
            boundView.addSubview(ball2!)
            boundView.addSubview(ball3!)
        default: break
        }
        
    }
    
    //MARK: - Add bricks
    
    var brickRows: Int {
        get { return defaults.objectForKey(Keys.Rows) as? Int ?? 3}
        set { defaults.setObject(newValue, forKey: Keys.Rows) }
    }
    
    func addBricks() {
        let brickGap: CGFloat = 10
        let topGap: CGFloat = boundView.frame.size.height / 6
        let middleLine: CGFloat = boundView.frame.maxY / 2       // bricks are not below this line
        let numberOfBricksInRow: CGFloat = 5
        let numberOfMaximumRow: CGFloat = 5
        let boundWidth = boundView.frame.size.width
        let brickWidth = (boundWidth - (numberOfBricksInRow+1)*brickGap) / numberOfBricksInRow
        let brickHeight = (middleLine - topGap - (numberOfMaximumRow+1) * brickGap) / numberOfMaximumRow
        
        
        
        for var i = 1; i <= brickRows; i++ {
            for var j = 1; j <= Int(numberOfBricksInRow); j++ {
                let brick = UIView(frame: CGRect(x: brickGap * CGFloat(j) + brickWidth * CGFloat(j-1), y: topGap + brickGap * CGFloat(i) + CGFloat(i-1) * brickHeight, width: brickWidth, height: brickHeight))
                brick.backgroundColor = UIColor.greenColor()
                breakout.addBricksBounds(brick, id: (i-1)*5+j)
                brick.tag = (i-1)*5+j
                boundView.addSubview(brick)
            }
        }
    }
    
    //MARK: - Add Score label
    
    var label: UILabel = UILabel() {
        didSet { label.text = "Score: \(score)" }
    }
    
    func addLabel() {
        let labelWidth: CGFloat = boundView.frame.size.width / 3
        let labelHeight: CGFloat = labelWidth / 6
        let labelY = labelHeight  // the topGap is 1/6 of total height
        label = UILabel(frame: CGRect(x: boundView.frame.size.width*2/3, y: labelY, width: labelWidth, height: labelHeight))
        
        boundView.addSubview(label)
    }
    
    //MARK: - Game Over
    
    func gameover() {
        let alert = UIAlertController(title: "Score: \(score)", message: "Game Over", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "restart", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        presentViewController(alert, animated: false, completion: {
            self.removeAllItems()
            self.restart()
        })
    }
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakout.collider.collisionDelegate = self
    }
    
    //MARK: - View did appear/disappear
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        restart()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeAllItems()
    }
    
    //MARK: - remove all items  and  restart
    
    func removeAllItems() {
        switch ballAmount {
        case 1:
            breakout.removeItem(ball1!)
            ball1?.removeFromSuperview()
        case 2:
            breakout.removeItem(ball1!)
            ball1?.removeFromSuperview()
            breakout.removeItem(ball2!)
            ball2?.removeFromSuperview()
        case 3:
            breakout.removeItem(ball1!)
            ball1?.removeFromSuperview()
            breakout.removeItem(ball2!)
            ball2?.removeFromSuperview()
            breakout.removeItem(ball3!)
            ball3?.removeFromSuperview()
        default: break
        }
        
        breakout.removeItem(paddle!)
        paddle?.removeFromSuperview()
        label.removeFromSuperview()
        animator.removeAllBehaviors()
        for var i = 1; i <= 25; i++ {
            if let brick = boundView.viewWithTag(i) {
                brick.removeFromSuperview()
            }
        }
        
        AppDelegate.Motion.Manager.stopAccelerometerUpdates()
    }
    
    func restart() {
        addPaddleAndBall()
        addBricks()
        addLabel()
        breakout.addPaddleBounds(paddle!)
        breakout.addWallBounds(boundView)
        
        switch ballAmount {
        case 1:
            breakout.addGravity(ball1!)
        case 2:
            breakout.addGravity(ball1!)
            breakout.addGravity(ball2!)
        case 3:
            breakout.addGravity(ball1!)
            breakout.addGravity(ball2!)
            breakout.addGravity(ball3!)
        default: break
        }
        
        animator.addBehavior(breakout)
        count = 0
        score = 0
        
        if breakout.hasGravity {
            let motionManager = AppDelegate.Motion.Manager
            if motionManager.accelerometerAvailable {
                motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                    self.breakout.gravity.gravityDirection = CGVector(dx: data!.acceleration.x, dy: -data!.acceleration.y)
                })
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
