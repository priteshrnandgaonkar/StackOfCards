//
//  CardsManager.swift
//  DynamicStackOfCards
//
//  Created by housing on 9/24/16.
//  Copyright © 2016 pritesh. All rights reserved.
//

import Foundation
import UIKit

struct Configuration {
    let cardOffset: Float
    let collapsedHeight:Float
    let expandedHeight:Float
    let cardHeight: Float
    let downwardThreshold:Float
    let upwardThreshold:Float
}

class CardsManager: NSObject, CardLayoutDelegate {
    
    var fractionToMove:Float = 0
    var cardState: CardState
    var configuration: Configuration
    
    weak var collectionView: UICollectionView?
    weak var cardsCollectionViewHeight: NSLayoutConstraint?

    var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    var previousTranslation: CGFloat = 0

    convenience override init() {
        let configuration = Configuration(cardOffset: 40, collapsedHeight: 200, expandedHeight: 500, cardHeight: 200, downwardThreshold: 20, upwardThreshold: 20)
        
        self.init(cardState: .Collapsed, configuration: configuration, collectionView: nil, heightConstraint: nil)
    }
    
    init(cardState: CardState, configuration: Configuration, collectionView: UICollectionView?, heightConstraint: NSLayoutConstraint?) {
        self.cardState = cardState
        self.configuration = configuration
        cardsCollectionViewHeight = heightConstraint
        self.collectionView = collectionView
        super.init()
        guard let cardsView = self.collectionView else {
            return
        }
        cardsView.delegate = self
        if let cardLayout = cardsView.collectionViewLayout as? CardLayout {
            cardLayout.delegate = self
        }
        panGesture = UIPanGestureRecognizer(target: self, action:#selector(self.cardsPanned))
        cardsView.addGestureRecognizer(panGesture)
        cardsView.isScrollEnabled = false
    }
    
    func cardsPanned(panGesture: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else {
            return
        }
        let translation = panGesture.translation(in: collectionView.superview!)
        collectionView.collectionViewLayout.invalidateLayout()
        
        let distanceMoved = translation.y
            guard let heightConstraint = self.cardsCollectionViewHeight else {
                return
            }
            
            switch panGesture.state {
            case .changed:
                
                print("CHANGED")
                heightConstraint.constant -= distanceMoved
                
                heightConstraint.constant = Swift.min(heightConstraint.constant, CGFloat(self.configuration.expandedHeight))
                heightConstraint.constant = Swift.max(heightConstraint.constant, CGFloat(self.configuration.collapsedHeight))
                
                self.cardState = .InTransit
                self.fractionToMove = Float(heightConstraint.constant - CGFloat(self.configuration.collapsedHeight))
                self.collectionView?.isScrollEnabled = false
                
                
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                    self.collectionView?.superview?.layoutIfNeeded()
                    
                    }, completion: nil)
                
            case .cancelled:
                fallthrough
            case .ended:
                
                print("Distance Moved \(self.previousTranslation)")
                
                if self.previousTranslation < 0 {
                    if heightConstraint.constant > CGFloat(self.configuration.collapsedHeight + self.configuration.upwardThreshold) {
                        heightConstraint.constant = CGFloat(self.configuration.expandedHeight)
                        self.cardState = .Expanded
                        self.panGesture.isEnabled = false
                    }
                    else {
                        heightConstraint.constant = CGFloat(self.configuration.collapsedHeight)
                        self.cardState = .Collapsed
                        self.panGesture.isEnabled = true
                    }
                }
                else {
                    if heightConstraint.constant < CGFloat(self.configuration.expandedHeight - self.configuration.downwardThreshold) {
                        heightConstraint.constant = CGFloat(self.configuration.collapsedHeight)
                        self.cardState = .Collapsed
                        self.panGesture.isEnabled = true
                    }
                    else {
                        
                        heightConstraint.constant = CGFloat(self.configuration.expandedHeight)
                        self.cardState = .Expanded
                        self.panGesture.isEnabled = false
                    }
                    
                }
                self.collectionView?.isScrollEnabled = !panGesture.isEnabled
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                    self.collectionView?.superview?.layoutIfNeeded()
                })
    
            default:
                break
            }
            
            self.previousTranslation = translation.y
            self.panGesture.setTranslation(CGPoint.zero, in: self.collectionView?.superview)
        }
}

extension CardsManager: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

            if scrollView.contentOffset.y < 0 {
                panGesture.isEnabled = true
                scrollView.isScrollEnabled = false
            }
    }
}
