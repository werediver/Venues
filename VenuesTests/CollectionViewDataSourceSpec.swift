//
//  CollectionViewDataSourceSpec.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/9/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import Quick
import Nimble
import UIKit
@testable import Venues

final class CollectionViewDataSourceSpec: QuickSpec {
    override func spec() {
        describe("CollectionViewDataSource") {
            var sut: CollectionViewDataSource<UICollectionViewCell, Int>!
            var collectionView: UICollectionView!

            beforeEach {
                sut = CollectionViewDataSource { cell, item in cell.tag = item }
                collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            }

            it("reflects the count of items") {
                let items = [1, 2, 3]
                sut.items = items
                expect(sut.collectionView(collectionView, numberOfItemsInSection: 0)) == items.count
            }
        }
    }
}
