//
//  CalculatorButton.swift
//  Calculator
//
//  Created by Christopher Thiebaut on 2/21/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import UIKit

class CalculatorButton: UIButton {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.addTarget(self, action: #selector(animateButtonPress), for: .touchUpInside)
    }
    
    @objc func animateButtonPress(){
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.repeatCount = 0
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: "pulse")
    }
}
