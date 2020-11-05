//
//  CollectionViewCell.swift
//  HomeWork
//
//  Created by Jim on 2020/2/18.
//  Copyright © 2020 Jim. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var showImageView: UIImageView!
    
    /// 扣掉中間的分隔線共5條
    static let width = floor((UIScreen.main.bounds.width - 3) / 4)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        widthConstraint.constant = Self.width
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
//        showImageView.image = nil
    }
    
}
