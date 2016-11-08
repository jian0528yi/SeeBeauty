//
//  LBCollectionViewCell.swift
//  SeeBeauty
//
//  Created by JLB on 2016/11/7.
//  Copyright © 2016年 LB. All rights reserved.
//

import UIKit
import Kingfisher

class LBCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!

    var image: LBImage {
        get {
            return LBImage()
        }

        set(newImage) {
            title?.text = newImage.title

            let url = URL(string: newImage.img)
            imageView?.kf.setImage(with: url)
        }
    }
}
