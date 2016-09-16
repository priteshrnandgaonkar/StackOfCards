//
//  CardView.swift
//  DynamicStackOfCards
//
//  Created by housing on 9/16/16.
//  Copyright © 2016 pritesh. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CardView: UICollectionViewCell {
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var content: UILabel!
    
    override func awakeFromNib() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
    
    override func prepareForInterfaceBuilder() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
}
