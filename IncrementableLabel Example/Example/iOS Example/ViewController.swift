//
//  ViewController.swift
//  IncrementableLabel
//
//  Created by Tom Baranes on 20/01/16.
//  Copyright © 2016 Recisio. All rights reserved.
//

import UIKit
import IncrementableLabel

class ViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var label1: IncrementableLabel!
    @IBOutlet weak var label2: IncrementableLabel!
    @IBOutlet weak var label3: IncrementableLabel!
    @IBOutlet weak var label4: IncrementableLabel!
    @IBOutlet weak var label5: IncrementableLabel!

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: IBAction
    
    @IBAction func startIncrementationPressed(sender: AnyObject) {
        label1.incrementFromValue(fromValue: 0, toValue: 100, duration: 3)
        
        label2.format = "%f"
        label2.incrementFromValue(fromValue: 0.0, toValue: 100.0, duration: 3)
        
        label3.option = .EaseInOut
        label3.stringFormatter = { value in
            return String(format: "EaseInOutAnimation: %d", Int(value))
        }
        label3.incrementFromValue(fromValue: 0.0, toValue: 100.0, duration: 3)
        
        label4.option = .EaseOut
        label4.attributedTextFormatter = { value in
            let string = String(format: "EaseOutAnimation + attributedString: %d", Int(value))
            let attributedString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16.0)])
            return attributedString
        }
        label4.incrementFromZero(toValue: 1000, duration: 1)
        
        label5.textColor = UIColor.black()
        label5.incrementFromZero(toValue: 1000, duration: 1) {
            self.label5.textColor = UIColor.green()
        }
    }

}

