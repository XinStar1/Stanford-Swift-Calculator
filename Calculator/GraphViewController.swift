//
//  GraphViewController.swift
//  Calculator
//
//  Created by azx on 15/12/17.
//  Copyright (c) 2015年 azx. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            let tap = UITapGestureRecognizer(target: self, action: "moveToCenter:")
            tap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tap)
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "slide:"))
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "zoom:"))
            
            graphView.scale = scale
            if storedGraph {
                graphView.graphCenter = center
            }
        }
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    struct Keys {
        static let Scale = "GraphViewController.scale"
        static let Center = "GraphViewController.center"
    }
    
    var storedGraph: Bool {
        get {
            if let _ = defaults.objectForKey(Keys.Center) as? [CGFloat] {
                return true
            }
            return false
        }
    }
    
    private var scale: CGFloat {
        get { return defaults.objectForKey(Keys.Scale) as? CGFloat ?? 50.0 }
        set { defaults.setObject(newValue, forKey: Keys.Scale) }
    }
    
    private var center: CGPoint {
        get {
            var center = graphView.center
            if let pointArray = defaults.objectForKey(Keys.Center) as? [CGFloat] {
                center.x = pointArray.first!
                center.y = pointArray.last!
            }
            return center
        }
        set {
            defaults.setObject([newValue.x, newValue.y], forKey: Keys.Center)
        }
    }
    
    func moveToCenter(gesture: UITapGestureRecognizer) {
        graphView.moveToCenter(gesture)
        if gesture.state == .Ended {
            center = graphView.graphCenter
        }
    }
    
    func slide(gesture: UIPanGestureRecognizer) {
        graphView.slide(gesture)
        if gesture.state == .Ended {
            center = graphView.graphCenter
        }
    }
    
    func zoom(gesture: UIPinchGestureRecognizer) {
        graphView.zoom(gesture)
        if gesture.state == .Ended {
            center = graphView.graphCenter
            scale = graphView.scale
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        graphView.setNeedsDisplay()
        print("\(defaults)")
    }
    
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return graphView
    }
    
    private var brain = CalculatorBrain()
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get { return brain.program }
        set { brain.program = newValue }
    }
    
    func y(x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        if let y = brain.evaluate() {
            return CGFloat(y)
        }
        return nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ValueViewController {
            if segue.identifier == "Popover Value" {
                destination.max = graphView.maxValue
                destination.min = graphView.minValue
                if let ppc = destination.popoverPresentationController {
                    ppc.delegate = self
                }
            }
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
