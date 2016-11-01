//
//  pictureCell.swift
//  Instragram
//
//  Created by olos on 06.03.2016.
//  Copyright © 2016 olos. All rights reserved.
//

import UIKit

class pictureCell: UICollectionViewCell {
    
    @IBOutlet weak var picImg: UIImageView!
    
    
    // default func
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //alignment
        let width = UIScreen.main.bounds.width
        
        picImg.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
        
    }
}
