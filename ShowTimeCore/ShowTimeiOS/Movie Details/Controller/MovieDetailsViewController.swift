//
//  MovieDetailViewController.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 27/12/21.
//

import Foundation
import UIKit
import ShowTimeCore

public final class MovieDetailsViewController: UIViewController {
    
    private(set) public lazy var movieDetailsView = view as! MovieDetailsView
    private var movieID: Int!
    private var movieDetailsloader: MovieDetailLoader!
    private var imageDataLoader: ImageDataLoader!
    private var makeURL: ((String) -> URL)!
    
    public convenience init(movieID: Int, movieDetailsloader: MovieDetailLoader, imageDataLoader: ImageDataLoader, makeURL: @escaping (String) -> URL) {
        self.init(nibName: nil, bundle: nil)
        self.movieID = movieID
        self.movieDetailsloader = movieDetailsloader
        self.imageDataLoader = imageDataLoader
        self.makeURL = makeURL
    }
    
    public override func loadView() {
        view = MovieDetailsView(frame: UIScreen.main.bounds)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        movieDetailsView.isLoading = true
        movieDetailsloader.load(movieID) { [weak self] result in
            guard let self = self else { return }
            
            if let movie = try? result.get(), let backdropImagePath = movie.backdropImagePath {
                self.imageDataLoader.load(from: self.makeURL(backdropImagePath), completion: { _ in
                    
                })
            }
            
            self.movieDetailsView.isLoading = false
        }
    }
}
