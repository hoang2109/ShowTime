//
//  PopularCollectionViewController.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeCore
import UIKit

public class PopularCollectionViewController: UICollectionViewController {
    private var popularMoviesLoader: PopularMoviesLoader?
    private var imageLoader: ImageDataLoader?
    private var makePosterImageURL: ((Movie) -> URL)?
    private var tasks = [IndexPath: ImageDataLoaderTask]()
    
    private var collectionModel = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public convenience init(popularMoviesLoader: PopularMoviesLoader, imageLoader: ImageDataLoader, makePosterImageURL: @escaping (Movie) -> URL) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.popularMoviesLoader = popularMoviesLoader
        self.imageLoader = imageLoader
        self.makePosterImageURL = makePosterImageURL
    }
    
    public override func viewDidLoad() {
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(load), for: UIControl.Event.valueChanged)
        load()
    }
    
    @objc func load() {
        collectionView.refreshControl?.beginRefreshing()
        let request = PopularMoviesRequest(page: 1)
        popularMoviesLoader?.load(request) { [weak self] result in
            if let data = try? result.get() {
                self?.collectionModel = data.items
            }
            
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionModel.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionModel[indexPath.row]
        let cell = PopularMovieCell()
        if let url = makePosterImageURL?(item) {
            cell.retryButton.isHidden = true
            cell.imageContainer.isShimmering = true
            
            
            let loadImage = { [weak self] in
                guard let self = self else { return }
                
                self.tasks[indexPath] = self.imageLoader?.load(from: url) { [weak cell] result in
                    if let data = try? result.get(), let image = UIImage(data: data) {
                        cell?.movieImageView.image = image
                    } else {
                        cell?.retryButton.isHidden = false
                    }
                    
                    cell?.imageContainer.isShimmering = false
                }
            }
            
            cell.onRetry = loadImage
            loadImage()
        }
        
        return cell
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}
