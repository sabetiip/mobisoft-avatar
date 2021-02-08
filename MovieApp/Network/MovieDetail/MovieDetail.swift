//
//  ResponseMovieDetail.swift
//  MovieApp
//
//  Created by Somayeh Sabeti on 2/6/21.
//  Copyright © 2021 Somayeh Sabeti. All rights reserved.
//

import Foundation

// MARK: - RequestMovieDetail
struct RequestMovieDetail: Codable {
    var i: String
}

// MARK: - ResponseMovieDetail
struct ResponseMovieDetail: Codable {
    let Title, Year, Rated: String?
    let Runtime, Genre, Director, Writer: String?
    let Actors, Plot: String?
    let Poster: String?
    let Metascore, imdbRating, imdbVotes, imdbID: String?
    let `Type`: String?
}

//MARK: - Service
class MovieDetailService: BaseWebService<RequestMovieDetail, ResponseMovieDetail> {
    
    init() {
        super.init(webServiceMethod: MakeWebService().movieDetail)
    }
    
    override func onSuccess(_ response: ResponseMovieDetail, allHeaderFields: [String : String]?) {
        super.onSuccess(response, allHeaderFields: allHeaderFields)
        
        ModelHandler.updateMovie(movieDetail: response)
    }
}

