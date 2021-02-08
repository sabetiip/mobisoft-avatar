//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Somayeh Sabeti on 2/7/21.
//  Copyright © 2021 Somayeh Sabeti. All rights reserved.
//

import UIKit
import TagListView

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var metascoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratedLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var genreView: TagListView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var actorsLabel: UILabel!
    
    var movieDetail: ResponseMovieDetail!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Action Methods
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Private Methods
    private func updateUI() {
        let origImage = UIImage(named: "back")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = .black
        
        posterImageView.loadImage(fromURL: movieDetail.Poster ?? "")
        ratingLabel.text = movieDetail.imdbRating
        voteLabel.text = movieDetail.imdbVotes
        titleLabel.text = movieDetail.Title
        yearLabel.text = movieDetail.Year
        ratedLabel.text = movieDetail.Rated
        runtimeLabel.text = movieDetail.Runtime
        summaryLabel.text = movieDetail.Plot
        writerLabel.text = movieDetail.Writer
        directorLabel.text = movieDetail.Director
        actorsLabel.text = movieDetail.Actors
        genreView.addTags(movieDetail.Genre?.components(separatedBy: ", ") ?? [])
    }
}
