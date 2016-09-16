//
//  CardLayout.swift
//  DynamicStackOfCards
//
//  Created by housing on 9/16/16.
//  Copyright © 2016 pritesh. All rights reserved.
//

import Foundation
import UIKit

enum CardState {
    case Expanded
    case InTransit
    case Collapsed
}


protocol CardLayoutDelegate {
    var fractionToMove: Float { get }
    var cardState: CardState { get }
    var cardOffset: Float { get }
    var cardHeight: Float{ get }
}

class CardLayout: UICollectionViewFlowLayout {

    var delegate: CardLayoutDelegate!
    

    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        cachedAttributes.removeAll()
        
        print("Prepare called with state \(delegate.cardState)")
        guard let numberOfItems = collectionView?.numberOfItems(inSection: 0) else {
            return
        }
                
        for index in 0..<numberOfItems {
            let layout = UICollectionViewLayoutAttributes()
            
            layout.frame = frameFor(index: index, cardState: delegate!.cardState)
//            frame.origin.y = CGFloat((8 * (index + 1)) + (cardHeight * index))
//            layout.frame = frame
            layout.zIndex = index
            cachedAttributes.append(layout)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("Attributes for rect called")

        guard let array = super.layoutAttributesForElements(in: rect) else {
            fatalError()
        }
        
        for attribute in array {
            let frame = cachedAttributes[attribute.indexPath.item].frame
            print("frame for index \(attribute.indexPath.item) and frame \(frame)")
            attribute.frame = frame
        }
        
        return array
    }
   
    func frameFor(index: Int, cardState: CardState) -> CGRect {
        var frame = CGRect(origin: CGPoint(x: 8, y:0), size: CGSize(width: UIScreen.main.bounds.width - 16, height: 200))
        var frameOrigin = frame.origin
        
        print("fractionto move \(delegate.fractionToMove) for index \(index)")

        switch cardState {
        case .Expanded:
            let val = (delegate.cardHeight * Float(index))
            frameOrigin.y = CGFloat(Float(8 * (index + 1)) + val)
            
        case .InTransit:
            if index > 0 {
                
                let val = CGFloat(8 + (delegate.cardOffset * Float(index)) + delegate.fractionToMove)
                print("intransit value \(val)")
                frameOrigin.y = val
            }
            
        case .Collapsed:
            if index > 0 {
                frameOrigin.y = CGFloat(8 + (delegate.cardOffset * Float(index)))
            }
        }
        frame.origin = frameOrigin
        return frame
    }
}
