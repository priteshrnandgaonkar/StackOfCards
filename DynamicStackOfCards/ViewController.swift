//
//  ViewController.swift
//  DynamicStackOfCards
//
//  Created by housing on 9/16/16.
//  Copyright © 2016 pritesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CardLayoutDelegate {

    var fractionToMove:Float = 0
    var cardState: CardState = .Collapsed
    var cardOffset: Float = 40
    let defaultCardsCollectionHeight:Float = 200
    let expandedHeight:Float = 500
    let cardHeight: Float = 200
    let downwardThreshold:Float = 50
    let upwardThreshold:Float = 50
    
    var previousTranslation:CGFloat = 0
    
    var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    @IBOutlet weak var cardsCollectionViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cardLayout = cardsCollectionView.collectionViewLayout as? CardLayout {
            cardLayout.delegate = self
        }
            // Do any additional setup after loading the view, typically from a nib.
        panGesture = UIPanGestureRecognizer(target: self, action:#selector(self.CardsPanned))
        cardsCollectionView.addGestureRecognizer(panGesture)
        cardsCollectionView.isScrollEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            panGesture.isEnabled = true
            scrollView.isScrollEnabled = false
        }
    }
    
    func CardsPanned(panGesture: UIPanGestureRecognizer) {
        
        let translation = panGesture.translation(in: view)
        cardsCollectionView.collectionViewLayout.invalidateLayout()
        
        let distanceMoved = translation.y //- previousTranslation
        
        switch panGesture.state {
        case .changed:

            cardsCollectionViewHeight.constant -= distanceMoved
            
            cardsCollectionViewHeight.constant = Swift.min(cardsCollectionViewHeight.constant, CGFloat(expandedHeight))
            cardsCollectionViewHeight.constant = Swift.max(cardsCollectionViewHeight.constant, CGFloat(defaultCardsCollectionHeight))

            cardState = .InTransit
            fractionToMove = Float(cardsCollectionViewHeight.constant - CGFloat(defaultCardsCollectionHeight))
            cardsCollectionView.isScrollEnabled = false
            
            cardsCollectionView.performBatchUpdates({
                self.cardsCollectionView.collectionViewLayout.invalidateLayout()
                self.view.layoutIfNeeded()
                
                }, completion: nil)
            
        case .cancelled:
            fallthrough
        case .ended:
            print("Distance Moved \(previousTranslation)")
            if previousTranslation < 0 {
                if cardsCollectionViewHeight.constant > CGFloat(defaultCardsCollectionHeight + upwardThreshold) {
                    cardsCollectionViewHeight.constant = CGFloat(expandedHeight)
                    cardState = .Expanded
                    panGesture.isEnabled = false
                }
                else {
                    cardsCollectionViewHeight.constant = CGFloat(defaultCardsCollectionHeight)
                    cardState = .Collapsed
                    panGesture.isEnabled = true
                }
            }
            else {
                if cardsCollectionViewHeight.constant < CGFloat(expandedHeight - downwardThreshold) {
                    cardsCollectionViewHeight.constant = CGFloat(defaultCardsCollectionHeight)
                    cardState = .Collapsed
                    panGesture.isEnabled = true
                }
                else {
                    
                    cardsCollectionViewHeight.constant = CGFloat(expandedHeight)
                    cardState = .Expanded
                    panGesture.isEnabled = false
                }

            }
            cardsCollectionView.isScrollEnabled = !panGesture.isEnabled

            UIView.animate(withDuration: 0.3, animations: {
                self.cardsCollectionView.collectionViewLayout.invalidateLayout()
                self.view.layoutIfNeeded()
            })

        default:
            break
        }
        
        previousTranslation = translation.y
        panGesture.setTranslation(CGPoint.zero, in: view)
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cardView = collectionView.dequeueReusableCell(withReuseIdentifier: "CardReuseID", for: indexPath) as? CardView else {
            fatalError("Failed to downcast to CardView")
        }
        cardView.header.text = "\(indexPath.row)"
        
        return cardView
    }
    
}

