//
//  String+Helpers.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 29/12/21.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
