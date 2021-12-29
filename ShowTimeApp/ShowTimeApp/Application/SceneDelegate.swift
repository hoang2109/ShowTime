//
//  SceneDelegate.swift
//  ShowTimeApp
//
//  Created by Hoang Nguyen on 24/12/21.
//

import UIKit
import ShowTimeCore
import ShowTimeiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var navController = UINavigationController()

    private static let baseURL = URL(string: "https://api.themoviedb.org")!
    private static let imageBaseURL = URL(string: "https://image.tmdb.org/t/p/w500/")!
    private static let backdropImageBaseURL = URL(string: "https://image.tmdb.org/t/p/w1280/")!
    private static let apiKey = "024482bc9d909c9d13da2a4ba57386ab"

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        navController.setViewControllers([makePopularCollectionScene()], animated: true)
        window.rootViewController = navController

        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    func makePopularCollectionScene() -> PopularCollectionViewController {
        let client = URLSessionHTTPClient(.init(configuration: .ephemeral))
        let authzClient = AuthenticatedHTTPClientDecorator(decoratee: client, apiKey: SceneDelegate.apiKey)
        let loader = RemotePopularMoviesLoader(client: authzClient) { request in
            let url = APIEndpoint.popularMovies(page: request.page, language: request.language).url(baseURL: SceneDelegate.baseURL)
            return URLRequest(url: url)
        }
        let imageLoader = RemoteImageDataLoader(client: client)
        
        let viewController = PopularCollectionUIComposer.compose(
            loader: MainQueueDispatchDecorator(decoratee: loader),
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader),
            baseImageURL: SceneDelegate.imageBaseURL
        ) { [weak self] movieID in
            guard let self = self else { return }
            let movieDetailViewController = self.makeMovieDetailViewController(movieID: movieID, client: authzClient)
            self.navController.pushViewController(movieDetailViewController, animated: true)
        }
        return viewController
    }
    
    func makeMovieDetailViewController(movieID: Int, client: HTTPClient) -> MovieDetailsViewController {
        let loader = RemoteMovieDetailLoader(client: client) { movieID in
            let url = APIEndpoint.movieDetail(id: movieID).url(baseURL: SceneDelegate.baseURL)
            return URLRequest(url: url)
        }
        let imageLoader = RemoteImageDataLoader(client: client)
        let viewController = MovieDetailsUIComposer.compose(
            movieID: movieID,
            movieDetailsLoader: MainQueueDispatchDecorator(decoratee: loader),
            imageDataLoader: MainQueueDispatchDecorator(decoratee: imageLoader),
            imageBaseURL: SceneDelegate.backdropImageBaseURL
        )
        return viewController
    }
}

