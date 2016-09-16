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
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    @IBOutlet weak var cardsCollectionViewHeight: NSLayoutConstraint!
    
    @IBAction func tappedOnInvalidate(_ sender: UIButton) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cardLayout = cardsCollectionView.collectionViewLayout as? CardLayout {
            cardLayout.delegate = self
        }
            // Do any additional setup after loading the view, typically from a nib.
        let gesture = UIPanGestureRecognizer(target: self, action:#selector(self.CardsPanned))
        cardsCollectionView.addGestureRecognizer(gesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            fractionToMove = Float(cardsCollectionViewHeight.constant - CGFloat(defaultCardsCollectionHeight))*((expandedHeight - defaultCardsCollectionHeight)/cardHeight)
            
             cardsCollectionView.collectionViewLayout.invalidateLayout()
            view.layoutIfNeeded()

        case .cancelled:
            fallthrough
        case .ended:
            
            if cardsCollectionViewHeight.constant > CGFloat(defaultCardsCollectionHeight + 50) {
                cardsCollectionViewHeight.constant = CGFloat(expandedHeight)
                cardState = .Expanded

            }
            else {
                cardsCollectionViewHeight.constant = CGFloat(defaultCardsCollectionHeight)
                cardState = .Collapsed
            }
            cardsCollectionView.collectionViewLayout.invalidateLayout()
            view.layoutIfNeeded()
            
            
        default:
            break
        }
        panGesture.setTranslation(CGPoint.zero, in: view)
       

        
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cardView = collectionView.dequeueReusableCell(withReuseIdentifier: "CardReuseID", for: indexPath) as? CardView else {
            fatalError("Failed to downcast to CardView")
        }
        
        cardView.header.text = "\(indexPath.item)"
        
        return cardView
    }
    
}

