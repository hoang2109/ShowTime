//
//  PopularMovieCell.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import UIKit

public class PopularMovieCell: UICollectionViewCell {
    private(set) public lazy var imageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) public lazy var movieImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.setTitle("⟳", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 45)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public override init(frame: CGRect) {
      super.init(frame: frame)
      configureUI()
    }

    public required init?(coder: NSCoder) {
      return nil
    }

    var onRetry: (() -> Void)?

    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    func configureUI() {
        contentView.addSubview(imageContainer)
        imageContainer.addSubview(movieImageView)
        imageContainer.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            
            movieImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageContainer.bottomAnchor.constraint(equalTo: movieImageView.bottomAnchor),
            movieImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: movieImageView.trailingAnchor),
            
            retryButton.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageContainer.bottomAnchor.constraint(equalTo: retryButton.bottomAnchor),
            retryButton.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: retryButton.trailingAnchor),
        ])
    }
}
