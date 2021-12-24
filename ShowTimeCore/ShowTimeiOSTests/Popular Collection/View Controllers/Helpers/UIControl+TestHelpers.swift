//
//  UIControl+TestHelpers.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
