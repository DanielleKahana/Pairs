//
//  GameViewController.swift
//  Pairs
//
//  Created by Ran Weiner on 3/28/18.
//  Copyright © 2018 Ran Weiner. All rights reserved.
//
import Foundation
import UIKit

class GameViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    lazy var collectionView: UICollectionView = {
        let c = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewLayout())
        return c
        
    }()
    
    var gameManager : Game?
    
    var countdownTimer = Timer()
    var seconds: Int = 60
    
    var allCells = [CollectionViewCell]()
    
    //var diffPassedOver : String!
   //var diffPassedOver = ""
   var diffPassedOver : String? = nil
    var cards = [Card]()
    
    
    let cardImages: [UIImage] = [
        UIImage(named: "backofcard")!,
        UIImage(named: "banana")!,
        UIImage(named: "apple")!,
        UIImage(named: "coconut")!,
        UIImage(named: "grape" )!,
        UIImage(named: "kiwi")!,
        UIImage(named: "orange")!,
        UIImage(named: "pear")!,
        UIImage(named: "pinapple")!,
        UIImage(named: "strawberry")!,
        UIImage(named: "watermelon")!
    ]
    
    var lastCell : CollectionViewCell?
    
    
    
  
    
    let TileMargin = CGFloat(2.0)
    
    
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        
        gameManager = Game(chosenDifficulty : Player.sharedInstance.playerDifficulty)
        cards = gameManager!.allCards
        startTimer()
        collectionView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNameLabel.text = Player.sharedInstance.name
       // gameManager = Game(chosenDifficulty: diffPassedOver!)
       // cards = gameManager!.allCards
        //startTimer()
        
    }

    override func didReceiveMemoryWarning() {		
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameManager!.numOfCols
       
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gameManager!.numOfRows
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let index = gameManager!.numOfCols * indexPath.section + indexPath.item
        
         cell.myLabel.text = String(cards[index].cardId)
        
        if cards[index].isMatched {
        
            cell.cardImage.image = cardImages[cards[index].cardId]  //show front of the card
            
        } else if cards[index].isOpened {
            cell.cardImage.image = cardImages[cards[index].cardId]  //show front of the card
        }
        else {
            cell.cardImage.image = cardImages[0] //show back of the card
        }
        
        allCells.append(cell)
        return cell
        
    }
   
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        let index = gameManager!.numOfCols * indexPath.section + indexPath.item
        
        if cell.canBeClicked == false {
            return
        }
        
        gameManager!.selectCard(index:  index)
        
        cards = gameManager!.allCards
        
        if cards[index].isMatched {
            
            cell.canBeClicked = false
            cell.isMatched = true
            lastCell?.canBeClicked = false
            lastCell?.isMatched = false
            
            cell.cardImage.image = cardImages[cards[index].cardId]
            CollectionViewCell.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil )
        
            lastCell = nil
            
            if gameManager!.isGameOver() {
                finishGameSuccessfully()
            }

        } else if cards[index].isOpened {
            if lastCell == nil {
                lastCell = cell
            }
    
            cell.cardImage.image = cardImages[cards[index].cardId]
            CollectionViewCell.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
        
        else {
            
            if lastCell != nil && lastCell != cell {
                
                disableAllCellsClicks()
                
                cell.cardImage.image = cardImages[cards[index].cardId]
                CollectionViewCell.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
                
                DispatchQueue.global(qos:.background).asyncAfter(deadline: .now()+1){
                    DispatchQueue.main.async {
                      
                        self.lastCell?.cardImage.image = self.cardImages[0]
                        CollectionViewCell.transition(with: self.lastCell!, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
                        
                        cell.cardImage.image = self.cardImages[0]
                        CollectionViewCell.transition(with: cell, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
                        
                        self.lastCell = nil
                        
                        self.enableAllCellsClicks()
                        
                    }
                }
                
                
            }
                
            
            else {
                
                cell.cardImage.image = self.cardImages[0]
                CollectionViewCell.transition(with: cell, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
                self.lastCell = nil
                
                
            }
          
            }
 
    
        
    }
    
   
    func finishGameSuccessfully(){
        Card.identifierFactory = 0
        endTimer()
        let storyboard = UIStoryboard(name: "Main" , bundle : nil)
        let viewController =   storyboard.instantiateViewController(withIdentifier: "EndGameViewController")
        navigationController?.pushViewController(viewController, animated: true)
        
        restart()
    }
    
    
    func startTimer(){
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        
    }
    
 @objc func updateTime(){
        timerLabel.text = "\(self.seconds)"
        if seconds > 0 {
            seconds -= 1
        }
        else {
            endTimer()
            gameOver()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }

    
    func gameOver(){
        Card.identifierFactory = 0
        //stop timer
        let alert = UIAlertController(title: "Oh No!", message: "You run out of time, better luck next time!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in
            self.navigationController?.dismiss(animated: true, completion: nil)
            //back to difficulty

        }))
        present(alert, animated: true, completion: {
        })
        
        restart()
        
        
    }
    
    func disableAllCellsClicks(){
        for cell in allCells{
            cell.canBeClicked = false
        }
    }
    
    func enableAllCellsClicks(){
        for cell in allCells{
            if cell.isMatched == false{
                cell.canBeClicked = true
            }
        }
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let colsCount = CGFloat(gameManager!.numOfCols)
        let rowsCount = CGFloat(gameManager!.numOfRows)
        let dimentionsW = (collectionView.frame.width / colsCount) - (colsCount * TileMargin )
        let dimentionsH = (collectionView.frame.height / rowsCount) - (rowsCount * TileMargin)
        return CGSize(width: dimentionsW, height: dimentionsH)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(TileMargin, TileMargin, TileMargin, TileMargin)
    }
    
    @IBAction func backToDifficulty(_ sender: UIButton) {
        Card.identifierFactory = 0
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func restart() {
        //collectionView.reloadData()
        diffPassedOver = Player.sharedInstance.playerDifficulty
        seconds = 60
        
    }
    
    
   
    
    
    

    

}
