//
//  MovieListViewController.swift
//  MovieApp
//
//  Created by Somayeh Sabeti on 2/6/21.
//  Copyright © 2021 Somayeh Sabeti. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var viewModel = MovieListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Movie List"
        spinner.hidesWhenStopped = true

        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
        viewModel.delegate = self
        viewModel.requestMovieList(searchText: "avatar")
    }
}

//MARK: - UITableViewDelegate & DataSource
extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        cell.movie = viewModel.movieList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id = viewModel.movieList[indexPath.row].imdbID {
            viewModel.requestMovieDetail(imdbID: id)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - MovieListViewModelDelegate
extension MovieListViewController: MovieListViewModelDelegate {
    func onStartGetMovieList() {
        spinner.startAnimating()
        tableView.isHidden = true
    }
    
    func onSuccessGetMovieList() {
        spinner.stopAnimating()
        tableView.isHidden = false
        tableView.reloadData()
    }

    func onFailedGetMovieList(errorText: String) {
        spinner.stopAnimating()
        print(errorText)
    }
    
    func onStartGetMovieDetail() {
    }
    
    func onSuccessGetMovieDetail(movieDetail: ResponseMovieDetail) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        viewController.movieDetail = movieDetail
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onFailedGetMovieDetail(errorText: String) {
        print(errorText)
    }
}
