//
//  PopularMovieCell+TestHelpers.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeiOS

extension PopularMovieCell {
    var isShowingImageLoadingIndicator: Bool {
        imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        movieImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        !retryButton.isHidden
    }
    
    func simulateRetryAction() {
        retryButton.simulate(event: .touchUpInside)
    }
}
