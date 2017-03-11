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
    @IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!

    var customView: OverviewView! { return self.view as? OverviewView }

    private let disposeBag = DisposeBag()
    private var dataSource: CollectionViewDataSource<PhotoCell, PhotoCellData>!

    private var refresh: Observable<()> {
        return Observable.of(
                self.rx.sentMessage(#selector(viewWillAppear(_:)))
                    .map { _ in },
                refreshBarButtonItem.rx.tap.asObservable()
            ).merge()
    }

    func setup(model: OverviewModelProtocol) {
        dataSource = CollectionViewDataSource { [weak self] cell, item in
            guard let `self` = self
            else { return }
            model.image(url: item.imageURL)
                .takeUntil(cell.rx.sentMessage(#selector(UICollectionViewCell.prepareForReuse)))
                .observeOn(MainScheduler.instance)
                .bindTo(cell.imageView.rx.image)
                .addDisposableTo(self.disposeBag)
        }
        customView.collectionView.dataSource = dataSource

        refresh
            .flatMapLatest(model.getOverviewData)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                guard let `self` = self
                else { return }
                self.dataSource.items = items
                self.customView.collectionView.reloadData()
            })
            .addDisposableTo(disposeBag)
    }
}

final class OverviewView: UIView {
    @IBOutlet var collectionView: UICollectionView!
    var refreshControl: UIRefreshControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshControl = UIRefreshControl()
        // TODO: Support the refresh-control.
        //collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true // Necessary for the refresh-control to work properly
    }
}

final class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

struct PhotoCellData {
    let imageURL: URL
}
