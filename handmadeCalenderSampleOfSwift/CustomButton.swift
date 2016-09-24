//
//  CustomButton.swift
//  
//
//  Created by Morioka Naoya on H28/09/10.
//  Copyright © 平成28年 Morioka Naoya. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomButton: UIButton {
    
    //角丸の半径
    @IBInspectable var cornerRadius: CGFloat = 0.0
    
    //枠
    @IBInspectable var borderColor: UIColor = UIColor.clearColor()
    @IBInspectable var borderWidth: CGFloat = 0.0
    
    override func drawRect(rect: CGRect) {
        //角丸
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = (cornerRadius > 0)
        
        //枠線
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = borderWidth
        
        super.drawRect(rect)
    }
    
}