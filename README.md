# Swappable UICollectionView Items

Trying to use UICollectionView to swap items using part of the re-ordering functionality available. 

**PlacementTimer** allows a delay before the item is swapped with the current dragged cell, this is set to 250ms. The cell can be moved around the grid without releasing it.

Although not perfect, it does show a possible method to replicate an item swap animation.

There are 2 variations to the swap which are changed with the Boolean **alwaysSwapWithOrigin**.

Setting **alwaysSwapWithOrigin** to **true** will ensure that that initial position that the user selects is always the location that the swap will occur. Demonstrated in the gif.

![alt tag](https://raw.githubusercontent.com/jbuda/swapCollectionViewItems/master/initial-origin-swap.gif)

Setting **alwaysSwapWithOrigin** to **false** will change the origin to that of the newly changed location depending if the user continues with the swapping of items.  Demonstrated in the gif.

![alt tag](https://raw.githubusercontent.com/jbuda/swapCollectionViewItems/master/new-origin-swap.gif)
