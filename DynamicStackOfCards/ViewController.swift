//
//  ViewController.swift
//  DynamicStackOfCards
//
//  Created by housing on 9/16/16.
//  Copyright © 2016 pritesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cardState: CardState = .Expanded
    var configuration = Configuration(cardOffset: 40, collapsedHeight: 200, expandedHeight: 500, cardHeight: 200, downwardThreshold: 20, upwardThreshold: 20)
    var manager: CardsManager = CardsManager()
    var previousTranslation:CGFloat = 0
    
    var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    @IBOutlet weak var cardsCollectionViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardsCollectionView.delegate = self
        manager = CardsManager(cardState: cardState, configuration: configuration, collectionView: cardsCollectionView, heightConstraint: cardsCollectionViewHeight)
        manager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, CardsManagerDelegate {
    
    func tappedOnCardsStack(cardsCollectionView: UICollectionView) {
        manager.cardState = .InTransit
        manager.updateView()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("In ViewController")
    }
}

