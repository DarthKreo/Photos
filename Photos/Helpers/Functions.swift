//
//  Functions.swift
//  Photos
//
//  Created by Владимир Кваша on 30.11.2020.
//

import UIKit

// MARK: - Functions

final class Functions {
    
    static func convertDateFormat(inputDate: String) -> String {
        let oldFormatter = ISO8601DateFormatter()
        guard let oldDate = oldFormatter.date(from: inputDate)
        else { return Constants.oldFormatterNoDate }
        
        let convertDateFormatter = DateFormatter()
        convertDateFormatter.dateFormat = Constants.dateFormat
        
        return convertDateFormatter.string(from: oldDate)
    }
}

// MARK: - Constants

private extension Functions {
    
    enum Constants {
        static let oldFormatterNoDate: String = "No data"
        static let dateFormat:String = "dd MMM. yyyy"
    }
}
