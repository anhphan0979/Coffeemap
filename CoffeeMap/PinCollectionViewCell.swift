//
//  PinCollectionViewCell.swift
//  CoffeeMap
//
//  Created by Phan Tiến Anh on 8/10/20.
//  Copyright © 2020 Phan Tiến Anh. All rights reserved.
//

import UIKit
import MapKit
class PinCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var addresslbl: UILabel!
    @IBOutlet weak var opentimelbl: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var closetimelbl: UILabel!
    var currentLocation: CLLocationCoordinate2D?

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    

}
