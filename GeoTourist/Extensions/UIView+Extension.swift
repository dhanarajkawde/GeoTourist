//
//  UIView+Extension.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 11/01/21.
//

import UIKit

enum DropShadowType {
    case rect, circle, dynamic
}

enum ViewSide {
    case Left, Right, Top, Bottom
}

// Common extension of UIView
extension UIView {
    
    /// Add shadow
    /// - Parameters:
    ///   - offset: offset
    ///   - color: color
    ///   - radius: corner radius
    ///   - opacity: opacity
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}
