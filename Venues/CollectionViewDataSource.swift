//
//  CollectionViewDataSource.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/8/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Foundation
import UIKit

final class CollectionViewDataSource<Cell: UICollectionViewCell, Item>: NSObject, UICollectionViewDataSource {
    private let prepareCell: (Cell, Item) -> ()

    var items: [Item] = []

    init(prepareCell: @escaping (Cell, Item) -> ()) {
        self.prepareCell = prepareCell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? items.count : 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(Cell.self)", for: indexPath) as! Cell
        let item = items[indexPath.row]
        prepareCell(cell, item)
        return cell;
    }

    // TODO: Support `UICollectionViewDataSourcePrefetching` (iOS 10+).
}
