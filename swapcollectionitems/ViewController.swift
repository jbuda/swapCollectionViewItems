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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionview.isScrollEnabled = false
    
    longPress = UILongPressGestureRecognizer(target: self, action:#selector(handleLongGesture))
    longPress.minimumPressDuration = 0.25
    collectionview.addGestureRecognizer(longPress)
    
    let queue = DispatchQueue(label: "com.buda.swapcollectionitems")
    
    placementTimer = DispatchSource.makeTimerSource(flags: [],queue:queue)
    placementTimer.scheduleRepeating(deadline: .now(), interval:.milliseconds(1000))
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
      
      placementTimer.resume()
      movingFromItemPath = path
      
      
      
      print("Cell selected ",movingFromItemPath)
      
      collectionview.beginInteractiveMovementForItem(at: path)
    case .changed:
      
      movingToItemPath = collectionview.indexPathForItem(at: movingPoints.current)
      
      movingPoints.current = g.location(in: collectionview)
      collectionview.updateInteractiveMovementTargetPosition(movingPoints.current)
    case .ended:
      placementTimer.cancel()
      collectionview.endInteractiveMovement()
      
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
    placementTimer.cancel()
//    
    collectionview.performBatchUpdates({
      self.collectionview.moveItem(at:fromPath, to:toPath)
      self.collectionview.moveItem(at:toPath, to:fromPath)
      }, completion:{ complete in
        print("Finished updates")
    })
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

