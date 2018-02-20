//
//  StyleExtensions.swift
//  Calculator
//
//  Created by Christopher Thiebaut on 2/19/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import UIKit

enum Styler {
    static func applyStyles() {
        //UIButton.appearance().cornerRadius = 20
    }
}

extension UIButton {
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
}
