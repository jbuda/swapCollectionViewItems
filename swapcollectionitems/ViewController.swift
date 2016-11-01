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
  var movingItems:(origin:IndexPath?,lifted:IndexPath?,placement:IndexPath?,previous:IndexPath?)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionview.isScrollEnabled = false
    
    longPress = UILongPressGestureRecognizer(target: self, action:#selector(handleLongGesture))
    longPress.minimumPressDuration = 0.30
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
    
    cell.backgroundColor = .red
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
      
      guard let origin = collectionview.indexPathForItem(at:g.location(in: collectionview)) else {
        break
      }
      
      placementTimer.resume()
      
      movingItems.origin = origin
      movingItems.lifted = origin
      
      collectionview.cellForItem(at: origin)?.backgroundColor = .yellow
      
      collectionview.beginInteractiveMovementForItem(at: movingItems.lifted!)
    case .changed:

      let p = g.location(in: collectionview)
      
      movingItems.placement = collectionview.indexPathForItem(at:p)
      
      collectionview.updateInteractiveMovementTargetPosition(p)
    case .ended:
      placementTimer.suspend()

      
      collectionview.cellForItem(at: movingItems.lifted!)?.backgroundColor = .red
      
      movingItems.origin = nil
      movingItems.lifted = nil
      movingItems.placement = nil
      movingItems.previous = nil
      collectionview.cancelInteractiveMovement()

    default:
      break
    }
    
  }
  
  func swapCells() {
    
    var second:IndexPath?
    
    guard let origin = movingItems.origin, var placement = movingItems.placement, let lifted = movingItems.lifted else {
      return
    }

    // can occur when second pass is origin going back to original location
    // collectionview error moving item at same from / to position
    if origin == placement {
      placement = lifted
    } else if origin != lifted {
      second = placement
      placement = lifted
    }
    
    self.placementTimer.suspend()
    
    DispatchQueue.main.async {
    
      self.collectionview.endInteractiveMovement()
      
      self.collectionview.performBatchUpdates({
        
          self.collectionview.moveItem(at:origin, to:placement)
        
          if let s = second {
            self.collectionview.moveItem(at:placement, to:s)
            self.collectionview.moveItem(at: s, to: origin)
          } else {
            self.collectionview.moveItem(at:placement, to:origin)
          }
        }, completion:{ complete in
          
          // only relevant when user continue changing item
          // gesture ended overrides and cancels this closure
          if let p = self.movingItems.placement {
            
            self.movingItems.lifted = p
            self.movingItems.placement = nil
            self.movingItems.previous = nil

            self.collectionview.beginInteractiveMovementForItem(at:self.movingItems.lifted!)
          } else {
            self.collectionview.cellForItem(at:placement)?.backgroundColor = .red
          }
          
          self.placementTimer.resume()
      })
    }
  }
  
  func cellPositionUpdate() {
    if let previous = movingItems.previous, let placement = movingItems.placement, let lifted = movingItems.lifted, previous == placement, placement != lifted  {
      swapCells()
    }

    movingItems.previous = movingItems.placement
  }
  
}

