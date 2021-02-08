//
//  MovieList.swift
//  MovieApp
//
//  Created by Somayeh Sabeti on 2/6/21.
//  Copyright © 2021 Somayeh Sabeti. All rights reserved.
//

import Foundation

// MARK: - RequestMovieList
struct RequestMovieList: Codable {
    var s: String
}

// MARK: - ResponseMovieList
struct ResponseMovieList: Codable {
    let Search: [Movie]?
    let totalResults, Response: String?
}

// MARK: Movie
struct Movie: Codable {
    let Title, Year, imdbID: String?
    let `Type`: MovieType?
    let Poster: String?
}

enum MovieType: String, Codable {
    case game
    case movie
    case series
}

//MARK: - Service
class MovieListService: BaseWebService<RequestMovieList, ResponseMovieList> {
    
    init() {
        super.init(webServiceMethod: MakeWebService().movieList)
    }
    
    override func onSuccess(_ response: ResponseMovieList, allHeaderFields: [String : String]?) {
        super.onSuccess(response, allHeaderFields: allHeaderFields)
        
        ModelHandler.deleteAllMovies()
        
        let movieList: [ResponseMovieDetail] = response.Search?.map({ (movie) -> ResponseMovieDetail in
            let responseMovie = ResponseMovieDetail(Title: movie.Title,
                                       Year: movie.Year,
                                       Rated: nil,
                                       Runtime: nil,
                                       Genre: nil,
                                       Director: nil,
                                       Writer: nil,
                                       Actors: nil,
                                       Plot: nil,
                                       Poster: movie.Poster,
                                       Metascore: nil,
                                       imdbRating: nil,
                                       imdbVotes: nil,
                                       imdbID: movie.imdbID,
                                       Type: movie.Type.map { $0.rawValue })
            return responseMovie
        }) ?? []
        
        ModelHandler.addMovieList(movieList: movieList)
    }
}

