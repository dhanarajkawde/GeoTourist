//
//  TourListTableViewCell.swift
//  GeoTourist
//
//  Created by Dhanraj Kawade on 09/01/21.
//

import UIKit

/// Class to load and show tour list
class TourListTableViewCell: UITableViewCell {

    // MARK:- IB Outlets
    @IBOutlet weak var viwBack: UIView!
    @IBOutlet weak var lblName: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.viwBack.layer.cornerRadius = 5
        self.viwBack.addShadow(offset: CGSize(width: 1.0, height: 1.0), color: UIColor.darkGray, radius: 3, opacity: 0.3)
    }
}
