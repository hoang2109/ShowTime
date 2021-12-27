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
    private var loader: MovieDetailLoader!
    
    public convenience init(movieID: Int, loader: MovieDetailLoader) {
        self.init(nibName: nil, bundle: nil)
        self.movieID = movieID
        self.loader = loader
    }
    
    public override func loadView() {
        view = MovieDetailsView(frame: UIScreen.main.bounds)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        movieDetailsView.isLoading = true
        loader.load(movieID) { [weak self] _ in
            self?.movieDetailsView.isLoading = false
        }
    }
}
