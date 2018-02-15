//
//  Extensions.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 1/28/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

extension UIView {
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(.pi * 2.0)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}

extension UIColor {
    /**
     An additional convenience initializer function that allows to init a UIColor object using a hex color value.
     
     :param: rgb UInt color hex value (f.e.: 0x990000 for a hex color code like #990000)
     :param: alpha Double Optional value that sets the alpha range 0=invisible / 1=totally visible
     
     */
    convenience init(rgb: UInt, alpha: Double = 1.0) {
        self.init(
            red:    CGFloat((rgb    & 0xFF0000) >> 16) / 255.0,
            green:  CGFloat((rgb    & 0x00FF00) >> 8)  / 255.0,
            blue:   CGFloat( rgb    & 0x0000FF)        / 255.0,
            alpha:  CGFloat(alpha)
        )
    }
}
