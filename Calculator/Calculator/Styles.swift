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
        UIButton.appearance().layer.cornerRadius = 20
        UIButton.appearance().clipsToBounds = true
        //UIButton.appearance().cornerRadius = 20
    }
}

