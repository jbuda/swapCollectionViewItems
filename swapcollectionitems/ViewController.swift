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
  var movingItems:(origin:IndexPath?,lifted:IndexPath?,placement:IndexPath?,second:IndexPath?)
  //var movingPoints = (current:CGPoint(x:0,y:0),previous:CGPoint(x:0,y:0))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionview.isScrollEnabled = false
    
    longPress = UILongPressGestureRecognizer(target: self, action:#selector(handleLongGesture))
    longPress.minimumPressDuration = 0.25
    collectionview.addGestureRecognizer(longPress)
    
    let queue = DispatchQueue(label: "com.swapcollectionitems")
    
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
    // return the index path of selected to prevent other cells reshuffling whilst moving cell around
    return movingItems.lifted!
  }
  
}

extension ViewController {
  
  @objc func handleLongGesture(g:UILongPressGestureRecognizer) {
    
    switch(g.state) {
    case .began:
      //movingPoints.current = g.location(in: collectionview)
      
      //guard let path = collectionview.indexPathForItem(at:movingPoints.current) else {
      //  break
      //}

      //placementTimer.resume()
     // movingItems.origin = path
      //movingItems.active = path
      
      collectionview.beginInteractiveMovementForItem(at: movingItems.lifted!)
    case .changed:
      print("Changed")
      //movingItems.first = collectionview.indexPathForItem(at: movingPoints.current)
      
      //movingPoints.current = g.location(in: collectionview)
      //collectionview.updateInteractiveMovementTargetPosition(movingPoints.current)
    case .ended:

      placementTimer.suspend()
      movingItems.origin = nil
      movingItems.lifted = nil
      movingItems.placement = nil
      collectionview.cancelInteractiveMovement()

    default:
      break
    }
    
  }
  
  func swapCells() {
    
    var second:IndexPath?
    
    guard let origin = movingItems.origin, var toPath = movingItems.placement else {
      return
    }
    
    if origin == toPath {
      DispatchQueue.main.async {
        self.collectionview.cancelInteractiveMovement()
      }

      return
    }
    
    if movingItems.origin != movingItems.lifted {
      toPath = movingItems.lifted!
      second = movingItems.placement!
    }
    
    self.placementTimer.suspend()
    
    DispatchQueue.main.async {
    
      self.collectionview.endInteractiveMovement()
      
      self.collectionview.performBatchUpdates({
        self.collectionview.moveItem(at:origin, to:toPath)
        
          if let s = second {
            self.collectionview.moveItem(at:toPath, to:s)
            self.collectionview.moveItem(at: s, to: origin)
          } else {
            self.collectionview.moveItem(at:toPath, to:origin)
          }
        }, completion:{ complete in
          // only relevant when user continue changing item
          // gesture ended overrides and cancels this closure
            self.movingItems.lifted = self.movingItems.placement
            self.movingItems.placement = nil

            self.collectionview.beginInteractiveMovementForItem(at: self.movingItems.lifted!)
            self.placementTimer.resume()

      })
    }
  }
  
  func cellPositionUpdate() {
//    if movingPoints.current == movingPoints.previous {
//      swapCells()
//    } else {
//      movingPoints.previous = movingPoints.current
//    }
  }
  
}

