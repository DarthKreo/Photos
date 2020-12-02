//
//  String Ext.swift
//  Photos
//
//  Created by Владимир Кваша on 30.11.2020.
//

// MARK: - extension String

extension String {
    
    func capitalizingFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirst() {
        self = self.capitalizingFirst()
    }
}
