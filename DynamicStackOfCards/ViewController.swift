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
    let expandedHeight:Float = 500;
    let cardHeight: Float = 200
    
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

        print(translation.y)

        switch panGesture.state {
        case .changed:

            cardsCollectionViewHeight.constant -= translation.y
            
            cardsCollectionViewHeight.constant = Swift.min(cardsCollectionViewHeight.constant, CGFloat(expandedHeight))
            cardsCollectionViewHeight.constant = Swift.max(cardsCollectionViewHeight.constant, CGFloat(defaultCardsCollectionHeight))

            cardState = .InTransit
            fractionToMove = Float(cardsCollectionViewHeight.constant - CGFloat(defaultCardsCollectionHeight))
            
             cardsCollectionView.collectionViewLayout.invalidateLayout()
            view.layoutIfNeeded()

        case .cancelled:
            fallthrough
        case .ended:
            
            if cardsCollectionViewHeight.constant > CGFloat(defaultCardsCollectionHeight + 50) {
                cardsCollectionViewHeight.constant = CGFloat(expandedHeight)
                cardState = .Expanded
                panGesture.isEnabled = false
                cardsCollectionView.isScrollEnabled = true
            }
            else {
                cardsCollectionViewHeight.constant = CGFloat(defaultCardsCollectionHeight)
                cardState = .Collapsed
                panGesture.isEnabled = true
            }
            cardsCollectionView.isScrollEnabled = !panGesture.isEnabled
            cardsCollectionView.collectionViewLayout.invalidateLayout()
            view.layoutIfNeeded()
            print(cardsCollectionView.contentSize)
            
        default:
            break
        }
        panGesture.setTranslation(CGPoint.zero, in: view)
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cardView = collectionView.dequeueReusableCell(withReuseIdentifier: "CardReuseID", for: indexPath) as? CardView else {
            fatalError("Failed to downcast to CardView")
        }
        print("dequeu \(indexPath.item)")
        cardView.header.text = "\(indexPath.row)"
        
        return cardView
    }
    
}

