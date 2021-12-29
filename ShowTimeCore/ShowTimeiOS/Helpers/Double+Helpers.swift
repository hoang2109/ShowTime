//
//  Double+Helpers.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 29/12/21.
//

import Foundation

extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = style
        formatter.calendar?.locale = Locale(identifier: "en-US ")
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}
