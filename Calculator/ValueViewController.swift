//
//  ValueViewController.swift
//  Calculator
//
//  Created by azx on 15/12/20.
//  Copyright (c) 2015年 azx. All rights reserved.
//

import UIKit

class ValueViewController: UIViewController {

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.font = UIFont.boldSystemFontOfSize(24)
        }
    }
    
    var max = CGFloat()
    var min = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "max:\(max)\nmin:\(min)"
    }
    
    override var preferredContentSize: CGSize {
        get {
            if textView != nil && presentingViewController != nil {
                return textView.sizeThatFits(presentingViewController!.view.bounds.size)
            }
            return super.preferredContentSize
        }
        set { super.preferredContentSize = newValue }
    }
}
