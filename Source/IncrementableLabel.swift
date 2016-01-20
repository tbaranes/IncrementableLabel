//
//  IncrementableLabel.swift
//  IncrementableLabel
//
//  Created by Tom Baranes on 20/01/16.
//  Copyright © 2016 Recisio. All rights reserved.
//

import UIKit

enum IncrementableLabelOptions {
    case Linear, EaseIn, EaseOut, EaseInOut
}

public class IncrementableLabel: UILabel {

    // MARK: Properties

    typealias StringFormatter = (Float) -> String
    typealias AttributedTextFormatter = (Float) -> NSAttributedString
    typealias IncrementableLabelCompletion = () -> Void
    
    /// An options indicating how you want to perform the incrementation:
    internal var option: IncrementableLabelOptions = .Linear
    
    /// A callback closure which permits a greater control on how the text (attributed or not) is formatted between each incrementation.
    internal var stringFormatter: StringFormatter?
    internal var attributedTextFormatter: AttributedTextFormatter?
    
    /// A callback closure that will be called once the incrementation is finished
    internal var incrementationCompletion: IncrementableLabelCompletion?

    /// The rate used when an option is used.
    public var easingRate: Float = 3.0
    
    /// The format is used to set the text in the label. You can set the format to %f in order to display decimals.
    public var format: String = "%d" {
        didSet {
            updateText()
        }
    }
    
    // MARK: Public methods
    
    /** The label's value during the incrementation */
    public func currentValue() -> Float {
        if progress >= duration {
            return toValue
        }
        let percent: Float = Float(progress / duration)
        return fromValue + (nextValueForCurrentOption(percent) * (toValue - fromValue))
    }
    
    /** Starts the incrementation fromValue to toValue */
    public func incrementFromValue(fromValue: Float, toValue: Float, duration: Float = 0.3) {
        startIncrementationFromValue(fromValue, toValue: toValue, duration: duration)
    }

    /** Starts the incrementation from the current value to toValue */
    public func incrementFromCurrentValueToValue(toValue: Float, duration: Float = 0.3) {
        startIncrementationFromValue(currentValue(), toValue: toValue, duration: duration)
    }

    /** Starts the incrementation from zero to toValue */
    public func incrementFromZero(toValue: Float, duration: Float = 0.3) {
        startIncrementationFromValue(0.0, toValue: toValue, duration: duration)
    }
    
    // MARK: Private properties
    
    private var timer: NSTimer?
    private var fromValue: Float = 0.0
    private var toValue: Float = 0.0
    
    private var duration: NSTimeInterval = 0.3
    private var progress: NSTimeInterval = 0.0
    private var lastUpdate: NSTimeInterval = 0.0

    // MARK: Private methods

    private func startIncrementationFromValue(fromValue: Float, toValue: Float, duration: Float) {
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = Double(duration)
        progress = 0
        lastUpdate = NSDate.timeIntervalSinceReferenceDate()
        
        self.timer?.invalidate()
        self.timer = nil
        
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.0/30.0, target: self, selector: "incrementValue:", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: UITrackingRunLoopMode)
        self.timer = timer
    }

    @objc private func incrementValue(sender: NSTimer) {
        let now = NSDate.timeIntervalSinceReferenceDate()
        progress += now - lastUpdate
        lastUpdate = now
        if progress >= duration {
            timer?.invalidate()
            timer = nil
            progress = duration
        }
        
        updateText()
        if progress == duration,
             let nonNilCompletion = incrementationCompletion {
                nonNilCompletion()
        }
    }
    
    private func updateText() {
        if let formatStringClosure = stringFormatter {
            text = formatStringClosure(currentValue())
        } else if let attributedTextClosure = attributedTextFormatter {
            attributedText = attributedTextClosure(currentValue())
        } else {
            let formatRange = Range<String.Index>(start: format.startIndex, end: format.endIndex)
            if format.rangeOfString("%(.*)(d|i)", options: .RegularExpressionSearch, range: formatRange) ==  formatRange {
                text = String(format: format, Int(currentValue()))
            } else {
                text = String(format: format, currentValue())
            }
        }
    }
    
}

private extension IncrementableLabel {
    
    // MARK: NextValue
    
    func nextValueForCurrentOption(value: Float) -> Float {
        switch option {
        case .Linear: return nextValueForLinearOption(value)
        case .EaseIn: return nextValueForEaseInOption(value)
        case .EaseOut: return nextValueForEaseInOutOption(value)
        case .EaseInOut: return nextValueForEaseInOutOption(value)
        }
    }
    
    func nextValueForLinearOption(value: Float) -> Float {
        return value
    }
    
    func nextValueForEaseInOption(value: Float) -> Float {
        return powf(value, easingRate)
    }
    
    func nextValueForEaseOutOption(value: Float) -> Float {
        return 1.0 - powf(1.0 - value, easingRate)
    }
    
    func nextValueForEaseInOutOption(var value: Float) -> Float {
        let sign: Float = easingRate % 2 == 0 ?  -1 : 1
        value *= 2
        if value < 1 {
            return 0.5 * powf(value, easingRate)
        }
        return sign * 0.5 * (powf(value - 2, easingRate) + sign * 2)
    }
}