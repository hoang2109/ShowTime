//
//  MovieDetailViewController.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 27/12/21.
//

import Foundation
import UIKit
import ShowTimeCore

public protocol MovieDetailsViewControllerDelegate {
    func didRequestMovieDetailsData()
}

public final class MovieDetailsViewController: UIViewController {
    
    private(set) public lazy var movieDetailsView = view as! MovieDetailsView
    private var delegate: MovieDetailsViewControllerDelegate?
    
    public convenience init(delegate: MovieDetailsViewControllerDelegate) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    public override func loadView() {
        view = MovieDetailsView(frame: UIScreen.main.bounds)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        delegate?.didRequestMovieDetailsData()
    }
    
    func configureNavigation() {
        navigationController?.navigationBar.tintColor = .white
    }
}

extension MovieDetailsViewController: MovieDetailsViewProtocol {
    func display(_ viewModel: MovieDetailsViewModel<UIImage>) {
        movieDetailsView.isLoading = viewModel.isLoading
        movieDetailsView.titleLabel.text = viewModel.title
        movieDetailsView.overviewLabel.text = viewModel.overView
        movieDetailsView.metaLabel.text = viewModel.meta
        movieDetailsView.bakcgroundImageView.setImageAnimated(viewModel.image)
    }
}
