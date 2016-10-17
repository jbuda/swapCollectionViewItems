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
  
  fileprivate var longPress:UILongPressGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    longPress = UILongPressGestureRecognizer(target: self, action:#selector(handleLongGesture))
    collectionview.addGestureRecognizer(longPress)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

extension ViewController:UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 16
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uicollectionviewcell", for: indexPath) as! CollectionViewItem
    
    cell.title.text = "\(indexPath.row+1)"
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    
  }
}

extension ViewController {
  
  @objc func handleLongGesture(g:UILongPressGestureRecognizer) {
    
    switch(g.state) {
    case .began:
      guard let path = collectionview.indexPathForItem(at: g.location(in: collectionview)) else {
        break
      }
      collectionview.beginInteractiveMovementForItem(at: path)
    case .changed:
      collectionview.updateInteractiveMovementTargetPosition(g.location(in: g.view!))
    case .ended:
      collectionview.endInteractiveMovement()
    default:
      break
    }
    
  }
  
}

