//
//  ViewController.swift
//  Venues
//
//  Created by Raman Fedaseyeu on 3/2/17.
//  Copyright © 2017 Raman Fedaseyeu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol OverviewModelProtocol {
    func getOverviewData() -> Observable<[PhotoCellData]>
    func image(url: URL) -> Observable<UIImage>
}

final class OverviewViewController: UIViewController {
    // TODO: Move all the view-specific code to a `UIView` subclass.
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!
    // TODO: Add a refresh-control.

    private let disposeBag = DisposeBag()
    private var dataSource: CollectionViewDataSource<PhotoCell, PhotoCellData>!

    private var refresh: Observable<()> {
        return Observable.of(
                self.rx.sentMessage(#selector(viewWillAppear(_:)))
                    .map { _ in },
                refreshBarButtonItem.rx.tap.asObservable()
            ).merge()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func setup(model: OverviewModelProtocol) {
        dataSource = CollectionViewDataSource { cell, item in
            model.image(url: item.imageURL)
                .takeUntil(cell.rx.sentMessage(#selector(UICollectionViewCell.prepareForReuse)))
                .bindTo(cell.imageView.rx.image)
                .addDisposableTo(self.disposeBag)
        }
        collectionView.dataSource = dataSource

        refresh
            .flatMapLatest(model.getOverviewData)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.dataSource.items = items
                self?.collectionView.reloadData()
            })
            .addDisposableTo(disposeBag)
    }
}

final class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

struct PhotoCellData {
    let imageURL: URL
}
