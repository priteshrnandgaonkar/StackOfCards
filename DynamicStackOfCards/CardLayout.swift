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
    var cardHeight: Float { get }
    var defaultCardsCollectionHeight:Float { get }
    var expandedHeight:Float { get }
}

class CardLayout: UICollectionViewLayout {

    var delegate: CardLayoutDelegate!
    var contentHeight: CGFloat = 0.0

    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        let collection = collectionView!
        let width = collection.bounds.size.width
        let height = contentHeight
        
        return CGSize(width: width, height: height)
    }
    
    override func prepare() {
        cachedAttributes.removeAll()
        contentHeight = delegate.cardState == .Expanded ? 0.0 : CGFloat(delegate.defaultCardsCollectionHeight + delegate.fractionToMove)
        
        guard let numberOfItems = collectionView?.numberOfItems(inSection: 0) else {
            return
        }
        
        for index in 0..<numberOfItems {
            let layout = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: 0))
            layout.frame = frameFor(index: index, cardState: delegate!.cardState, translation: delegate.fractionToMove)
            if delegate.cardState == .Expanded {
                contentHeight += 8 + layout.frame.size.height
            }
            layout.zIndex = index
            layout.isHidden = false
            
            cachedAttributes.append(layout)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let array = super.layoutAttributesForElements(in: rect) else {
//            fatalError()
//        }
//        
//        for attribute in array {
//            let frame = cachedAttributes[attribute.indexPath.row].frame
//            attribute.frame = frame
//
//        }
//
//        return array


        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cachedAttributes {
            if attributes.frame.intersects(rect) {
//                layoutAttributes.append(attributes)
                layoutAttributes.append(cachedAttributes[attributes.indexPath.item])
            }

        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    func frameFor(index: Int, cardState: CardState, translation: Float) -> CGRect {
        var frame = CGRect(origin: CGPoint(x: 8, y:0), size: CGSize(width: UIScreen.main.bounds.width - 16, height: 200))
        var frameOrigin = frame.origin
        switch cardState {
        case .Expanded:
            let val = (delegate.cardHeight * Float(index))
            frameOrigin.y = CGFloat(Float(8 * (index)) + val)
            
        case .InTransit:
            if index > 0 {
                
                let collapsedY = 8.0 + (delegate.cardOffset * Float(index))
                let finalDistToMove = Swift.abs(((8.0 + delegate.cardHeight) * Float(index)) - collapsedY)
                let fract = (finalDistToMove * translation)/(delegate.expandedHeight - delegate.defaultCardsCollectionHeight)
                let val = CGFloat(8 + (delegate.cardOffset * Float(index)) + fract)
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
