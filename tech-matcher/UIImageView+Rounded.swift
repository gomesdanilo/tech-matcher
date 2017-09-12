//
//  UIImageView+Rounded.swift
//  tech-matcher
//
//  Created by Danilo Gomes on 12/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

// ROUNDED

extension UIImageView {

    func setBorder(width : CGFloat, color : UIColor?){
        self.layer.borderWidth = width
        self.layer.borderColor = color?.cgColor
    }
    
    func setRound(cornerRadius : CGFloat){
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
    
}
