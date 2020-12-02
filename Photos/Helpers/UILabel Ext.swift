//
//  UILabel Ext.swift
//  Photos
//
//  Created by Владимир Кваша on 30.11.2020.
//

import UIKit

// MARK: - extension UILabel

extension UILabel {
    func addImage(image: String, text: String) {
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: image)
        
        guard let size = imageAttachment.image?.size else { return }
        let imageOffsetY: CGFloat = -(size.height - self.font.pointSize) / 2
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: size.width, height: size.height)
        
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        let finalText = " " + text
        let textAfterIcon = NSAttributedString(string: finalText)
        completeText.append(textAfterIcon)
        
        self.textAlignment = .left
        self.attributedText = completeText
    }
}
