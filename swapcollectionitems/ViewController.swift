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
  var movingItemPaths:(origin:IndexPath?,active:IndexPath?,first:IndexPath?,second:IndexPath?)
  var movingPoints = (current:CGPoint(x:0,y:0),previous:CGPoint(x:0,y:0))
  //var isItemActive:Bool = false
  
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
    //print("Target Index Path :",originalIndexPath,proposedIndexPath)
    // return the index path of selected to prevent other cells reshuffling whilst moving cell around
    return movingItemPaths.active!
  }
  
}

extension ViewController {
  
  @objc func handleLongGesture(g:UILongPressGestureRecognizer) {
    
    switch(g.state) {
    case .began:
      movingPoints.current = g.location(in: collectionview)
      
      guard let path = collectionview.indexPathForItem(at:movingPoints.current) else {
        break
      }

     // isItemActive = true
      placementTimer.resume()
      movingItemPaths.origin = path
      movingItemPaths.active = path
      
      print("Cell active ",movingItemPaths.origin)
      
      collectionview.beginInteractiveMovementForItem(at: movingItemPaths.active!)
    case .changed:
      
      movingItemPaths.first = collectionview.indexPathForItem(at: movingPoints.current)
      
      movingPoints.current = g.location(in: collectionview)
      collectionview.updateInteractiveMovementTargetPosition(movingPoints.current)
    case .ended:
      
      //isItemActive = false
      placementTimer.suspend()
      movingItemPaths.origin = nil
      movingItemPaths.active = nil
      movingItemPaths.first = nil
      collectionview.cancelInteractiveMovement()

    default:
      break
    }
    
  }
  
  func swapCells() {
    
    var second:IndexPath?
    
    guard let origin = movingItemPaths.origin, var toPath = movingItemPaths.first else {
      return
    }
    
    if origin == toPath {
      DispatchQueue.main.async {
        self.collectionview.cancelInteractiveMovement()
      }

      return
    }
    
    print("MADE IT HERE")
    
    if movingItemPaths.origin != movingItemPaths.active {
      toPath = movingItemPaths.active!
      second = movingItemPaths.first!
    }
    
    print("Moving Paths",movingItemPaths)
    print("Can swap",origin,toPath)
    
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
          print("Finished updates")
        
         // if self.isItemActive {
            
            print("Continue movement with active cell at",self.movingItemPaths.active!)
            
            //self.movingItemPaths.original = self.movingItemPaths.first
            self.movingItemPaths.active = self.movingItemPaths.first
            self.movingItemPaths.first = nil

            self.collectionview.beginInteractiveMovementForItem(at: self.movingItemPaths.active!)
            self.placementTimer.resume()
            
         // } else {
            
           // print("Drop the cell")
            
           // self.collectionview.endInteractiveMovement()
            
                       // self.movingItemPaths.origin = nil
            //self.movingItemPaths.first = nil
            
         // }
      })
    }
  }
  
  func cellPositionUpdate() {
    //print("Cell positions ",movingPoints)
    if movingPoints.current == movingPoints.previous {
      swapCells()
    } else {
      movingPoints.previous = movingPoints.current
    }
  }
  
}

