//
//  UIRefreshControl+TestHelpers.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import UIKit

extension UIRefreshControl {
    func simulateRefreshing() {
        simulate(event: .valueChanged)
    }
}
