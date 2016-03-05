//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by azx on 15/12/24.
//  Copyright © 2015年 azx. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior
{
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    struct Keys {
        static let Velocity = "BreakoutBehavior.magnitude"
        static let HasGravity = "BreakoutBehavior.hasGravity"
    }
    
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedDynamicAnimator = UICollisionBehavior()
        lazilyCreatedDynamicAnimator.translatesReferenceBoundsIntoBoundary = true
        return lazilyCreatedDynamicAnimator
    }()
    
    lazy var elastic: UIDynamicItemBehavior = {
        let elasticBehavior = UIDynamicItemBehavior()
        elasticBehavior.allowsRotation = false
        elasticBehavior.resistance = 0
        elasticBehavior.friction = 0
        elasticBehavior.elasticity = 1
        return elasticBehavior
    }()
    
    let gravity = UIGravityBehavior()
    
    override init() {
        super.init()
        self.addChildBehavior(collider)
        self.addChildBehavior(elastic)
        self.addChildBehavior(gravity)
    }
    
    private struct Bounds {
        static let BottomWall = "Bottom Bound"
        static let Paddle = "Paddle Bound"
        static let Brick = "Brick Bound"
    }
    
    func addWallBounds(bound: UIView) {
        collider.addBoundaryWithIdentifier(Bounds.BottomWall, fromPoint: CGPoint(x: 0, y: bound.frame.size.height), toPoint: CGPoint(x: bound.frame.size.width, y: bound.frame.size.height))
    }
    
    func addPaddleBounds(paddle: UIView) {
        collider.removeBoundaryWithIdentifier(Bounds.Paddle)
        collider.addBoundaryWithIdentifier(Bounds.Paddle, forPath: UIBezierPath(ovalInRect: paddle.frame))
    }
    
    func addBricksBounds(brick: UIView, id: Int) {
        collider.addBoundaryWithIdentifier(Bounds.Brick + "\(id)", forPath: UIBezierPath(rect: brick.frame))
    }
    
    var magnitude: CGFloat {
        get { return defaults.objectForKey(Keys.Velocity) as? CGFloat ?? 2}
        set { defaults.setObject(newValue, forKey: Keys.Velocity) }
    }
    
    func pushBall(ball: UIView) {
        if let animator = dynamicAnimator {
            let push = UIPushBehavior(items:[ball], mode: UIPushBehaviorMode.Instantaneous)
            let angle = CGFloat(-M_PI * Double(arc4random()%1000)/1000)
            push.setAngle(angle, magnitude: magnitude)
            
            animator.addBehavior(push)
        }
    }
    
    func removeItem(item: UIView) {
        collider.removeItem(item)
        elastic.removeItem(item)
        gravity.removeItem(item)  // !!!!!!!!!!!!!!!!!!!!!!!!
    }
    
    func addColliderAndElastic(item: UIView) {
    }
    
    var hasGravity: Bool {
        get { return defaults.objectForKey(Keys.HasGravity) as? Bool ?? false }
        set { defaults.setObject(newValue, forKey: Keys.HasGravity) }
    }
    
    func addGravity(item: UIView) {
        if hasGravity {
            gravity.addItem(item)
        }
        // Whether has gravity or not, add collider and elastic to ball
        collider.addItem(item)
        elastic.addItem(item)
    }
}
