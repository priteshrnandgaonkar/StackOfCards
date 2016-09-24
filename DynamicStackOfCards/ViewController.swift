//
//  ViewController.swift
//  DynamicStackOfCards
//
//  Created by housing on 9/16/16.
//  Copyright © 2016 pritesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cardState: CardsPosition = .Expanded
    var configuration = Configuration(cardOffset: 40, collapsedHeight: 200, expandedHeight: 500, cardHeight: 200, downwardThreshold: 20, upwardThreshold: 20)
    var manager: CardsStack = CardsStack()
    var previousTranslation:CGFloat = 0
    
    var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    @IBOutlet weak var cardsCollectionViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        manager = CardsManager(cardState: cardState, configuration: configuration, collectionView: cardsCollectionView, heightConstraint: cardsCollectionViewHeight)
        manager = CardsStack(cardsState: cardState, configuration: configuration, collectionView: cardsCollectionView, collectionViewHeight: cardsCollectionViewHeight)
        manager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDataSource, CardsManagerDelegate {
    
    func tappedOnCardsStack(cardsCollectionView: UICollectionView) {
        manager.updateView(with: .Expanded)
    }

    func cardsCollectionView(_ cardsCollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cards didSelect")
    }
    
    func cardsCollectionView(_ cardsCollectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("Cards WillDisplay")
    }

    
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

