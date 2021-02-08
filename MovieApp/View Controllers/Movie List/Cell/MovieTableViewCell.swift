//
//  MovieTableViewCell.swift
//  MovieApp
//
//  Created by Somayeh Sabeti on 2/6/21.
//  Copyright © 2021 Somayeh Sabeti. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var movie: Movie? {
        didSet {
            guard let movie = movie else { return }
            
            if let urlStr = movie.Poster {
                posterImageView.loadImage(fromURL: urlStr)
            }
            titleLabel.text = movie.Title
            yearLabel.text = movie.Year
            typeLabel.text = movie.Type.map { $0.rawValue }?.uppercased()
        }
    }
}
