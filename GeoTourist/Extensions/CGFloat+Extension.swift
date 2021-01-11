//
//  CGFloat+Extension.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 11/01/21.
//

import UIKit

extension CGFloat {
    
    /// generate random number
    /// - Returns: <#description#>
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
