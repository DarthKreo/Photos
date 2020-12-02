//
//  UIAlertController.swift
//  Photos
//
//  Created by Владимир Кваша on 02.12.2020.
//

import UIKit

// MARK: - extension UIViewController

extension UIViewController {
    
    func alert(title: String, message: String, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
