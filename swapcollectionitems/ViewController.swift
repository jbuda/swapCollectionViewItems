//
//  ViewController.swift
//  swapcollectionitems
//
//  Created by Janusz on 17/10/2016.
//
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var collectionview:UICollectionView!
  
  var placementTimer:DispatchSourceTimer!
  var longPress:UILongPressGestureRecognizer!
  var movingFromItemPath:IndexPath!
  var movingToItemPath:IndexPath!
  var movingPoints = (current:CGPoint(x:0,y:0),previous:CGPoint(x:0,y:0))
  var isItemActive:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionview.isScrollEnabled = false
    
    longPress = UILongPressGestureRecognizer(target: self, action:#selector(handleLongGesture))
    longPress.minimumPressDuration = 0.25
    collectionview.addGestureRecognizer(longPress)
    
    let queue = DispatchQueue(label: "com.buda.swapcollectionitems")
    
    placementTimer = DispatchSource.makeTimerSource(flags: [],queue:queue)
    placementTimer.scheduleRepeating(deadline: .now(), interval:.milliseconds(250))
    placementTimer.setEventHandler(handler: cellPositionUpdate)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

extension ViewController:UICollectionViewDataSource,UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 9
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uicollectionviewcell", for: indexPath) as! CollectionViewItem
    
    cell.title.text = "\(indexPath.row+1)"
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    // required for interactive movement
  }
  
  func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
    //print("Target Index Path :",originalIndexPath,proposedIndexPath)
    // return the index path of selected to prevent other cells reshuffling as moving cell around
    return movingFromItemPath
  }
  
}

extension ViewController {
  
  @objc func handleLongGesture(g:UILongPressGestureRecognizer) {
    
    switch(g.state) {
    case .began:
      //movingPoints. = g.location(in: collectionview)
      movingPoints.current = g.location(in: collectionview)
      
      guard let path = collectionview.indexPathForItem(at:movingPoints.current) else {
        break
      }

      isItemActive = true
      placementTimer.resume()
      movingFromItemPath = path
      
      print("Cell selected ",movingFromItemPath)
      
      collectionview.beginInteractiveMovementForItem(at: path)
    case .changed:
      
      print("still moving")
      
      movingToItemPath = collectionview.indexPathForItem(at: movingPoints.current)
      
      movingPoints.current = g.location(in: collectionview)
      collectionview.updateInteractiveMovementTargetPosition(movingPoints.current)
    case .ended:
      
      isItemActive = false
      //placementTimer.suspend()
      //collectionview.endInteractiveMovement()
      
      swapCells()

    default:
      break
    }
    
  }
  
  func swapCells() {
    
    guard let toPath = movingToItemPath, let fromPath = movingFromItemPath else {
      return
    }
    
    print("Swapping ",toPath,fromPath)
//    

    
    DispatchQueue.main.async {
    
      self.collectionview.endInteractiveMovement()
      
      self.collectionview.performBatchUpdates({
        self.collectionview.moveItem(at:fromPath, to:toPath)
        self.collectionview.moveItem(at:toPath, to:fromPath)
        }, completion:{ complete in
          print("Finished updates")
        
          if self.isItemActive {
            
            self.movingFromItemPath = self.movingToItemPath
            self.movingToItemPath = nil
            self.collectionview.beginInteractiveMovementForItem(at: toPath)
            
          } else {
            
            self.placementTimer.suspend()
            
            self.movingToItemPath = nil
            self.movingFromItemPath = nil
          }
      })
    }
  }
  
  func cellPositionUpdate() {
    print("Cell positions ",movingPoints)
    if movingPoints.current == movingPoints.previous {
      swapCells()
    } else {
      movingPoints.previous = movingPoints.current
    }
  }
  
}

