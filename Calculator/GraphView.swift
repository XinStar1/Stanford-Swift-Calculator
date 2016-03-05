//
//  GraphView.swift
//  Calculator
//
//  Created by azx on 15/12/18.
//  Copyright (c) 2015年 azx. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func y(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    var graphCenter: CGPoint = CGPoint() {
        didSet {
            resetOrigin = true
            setNeedsDisplay()
        }
        
    }
    
    private var resetOrigin: Bool = false
    
    
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    var color: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    weak var dataSource: GraphViewDataSource?
    
    
    @IBInspectable
    var scale: CGFloat = 10 { didSet { setNeedsDisplay() } }
    
    var maxValue = CGFloat()
    var minValue = CGFloat()
    private var firstCompare: Bool = true
    
    override func drawRect(rect: CGRect) {
        
        if !resetOrigin {
            graphCenter = center
        }
        
        AxesDrawer(contentScaleFactor: contentScaleFactor).drawAxesInRect(bounds, origin: graphCenter, pointsPerUnit: scale)
        
        
        var path = UIBezierPath()
        var firstPixel = true
        color.set()

        for var i = 0; i <= Int(bounds.size.width * contentScaleFactor); i++ {
            var point = CGPoint()
            point.x = CGFloat(i) / contentScaleFactor
            if let y = dataSource?.y((point.x - graphCenter.x) / scale) {
                if !y.isNormal && !y.isZero {
                    continue
                }
                point.y = graphCenter.y - y * scale
                
                if firstPixel {
                    path.moveToPoint(point)
                    firstPixel = false
                } else {
                    path.addLineToPoint(point)
                }
                
                if firstCompare {
                    maxValue = y
                    minValue = y
                    firstCompare = false
                }
                if y >= maxValue { maxValue = y }
                if y <= minValue { minValue = y }
            }
        }
        path.stroke()
        
    }
    
    func moveToCenter(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            graphCenter = gesture.locationInView(self)
        }
    }
    
//    func slide(gesture: UIPanGestureRecognizer) {
//        switch gesture.state {
//        case .Ended: fallthrough
//        case .Changed:
//            let translation = gesture.translationInView(self)
//            graphCenter.x += translation.x
//            graphCenter.y += translation.y
//            gesture.setTranslation(CGPointZero, inView: self)
//        default: break
//        }
//    }

    var snapshot: UIView?  // create a temporary View for slide so that we needn't create graphView all the time
    
    func slide(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            snapshot?.alpha = 0.5
            self.addSubview(snapshot!)
        case .Changed:
            let translation = gesture.translationInView(self)
            snapshot?.center.x += translation.x
            snapshot?.center.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        case .Ended:
            graphCenter.x += snapshot!.frame.origin.x
            graphCenter.y += snapshot!.frame.origin.y
            snapshot?.removeFromSuperview()
            snapshot = nil
        default: break
        }
    }
    
//    func zoom(gesture: UIPinchGestureRecognizer) {
//        if gesture.state == .Changed {
//            scale *= gesture.scale
//            gesture.scale = 1
//        }
//    }
    
    func zoom(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Began:
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            snapshot!.alpha = 0.5
            self.addSubview(snapshot!)
        case .Changed:
            let touchPoint = gesture.locationInView(self)
            snapshot!.frame.size.width *= gesture.scale
            snapshot!.frame.size.height *= gesture.scale
            snapshot!.frame.origin.x += (snapshot!.frame.origin.x - touchPoint.x) * (gesture.scale - 1)
            snapshot!.frame.origin.y += (snapshot!.frame.origin.y - touchPoint.y) * (gesture.scale - 1)
            gesture.scale = 1
        case .Ended:
            let changedScale = snapshot!.frame.size.height / self.frame.height
            scale *= changedScale
            graphCenter.x = snapshot!.frame.origin.x + graphCenter.x * changedScale
            graphCenter.y = snapshot!.frame.origin.y + graphCenter.y * changedScale
            snapshot!.removeFromSuperview()
            snapshot = nil
        default: break
        }
    }
    
    
}
