//
//  MovieListViewModel.swift
//  MovieApp
//
//  Created by Somayeh Sabeti on 2/6/21.
//  Copyright © 2021 Somayeh Sabeti. All rights reserved.
//

import Foundation

protocol MovieListViewModelDelegate: class {
    func onStartGetMovieList()
    func onSuccessGetMovieList()
    func onFailedGetMovieList(errorText: String)
    
    func onStartGetMovieDetail()
    func onSuccessGetMovieDetail(movieDetail: ResponseMovieDetail)
    func onFailedGetMovieDetail(errorText: String)
}

class MovieListViewModel {
    
    let movieListService = MovieListService()
    let movieDetailService = MovieDetailService()
    
    var movieList: [Movie] = []
    
    weak var delegate: MovieListViewModelDelegate?
    
    func requestMovieList(searchText: String) {
        
        ModelHandler.fetchMovieList { [weak self] (movieList) in
            guard let self = self else { return }
            if let list = movieList {
                self.movieList = list.map({ (movieDBObj) -> Movie in
                    let movie = Movie(Title: movieDBObj.title,
                                      Year: movieDBObj.year,
                                      imdbID: movieDBObj.imdbID,
                                      Type: MovieType(rawValue: movieDBObj.type!),
                                      Poster: movieDBObj.poster)
                    return movie
                })
                self.delegate?.onSuccessGetMovieList()
                
            } else {
                self.movieListService.delegateStruct = BaseWebServiceStruct(onStart: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.delegate?.onStartGetMovieList()
                    }, onSuccessObject: { [weak self] (response) in
                        guard let self = self else {
                            return
                        }
                        self.movieList = response.Search ?? []
                        self.delegate?.onSuccessGetMovieList()
                    }, onFailed: { [weak self] (errorText) in
                        guard let self = self else {
                            return
                        }
                        self.delegate?.onFailedGetMovieList(errorText: errorText)
                })
                self.movieListService.request(RequestMovieList(s: searchText))
            }
        }
    }
    
    func requestMovieDetail(imdbID: String) {
        
        ModelHandler.fetchMovie(imdbID: imdbID) { [weak self] (movieDBObj) in
            guard let self = self else { return }
            
            if let movieDB = movieDBObj, let runtime = movieDB.runtime, !runtime.isEmpty {
                let response = ResponseMovieDetail(Title: movieDB.title, Year: movieDB.year, Rated: movieDB.rated, Runtime: movieDB.runtime, Genre: movieDB.genre, Director: movieDB.director, Writer: movieDB.writer, Actors: movieDB.actors, Plot: movieDB.plot, Poster: movieDB.poster, Metascore: movieDB.metascore, imdbRating: movieDB.imdbRating, imdbVotes: movieDB.imdbVotes, imdbID: movieDB.imdbID, Type: movieDB.type)
                self.delegate?.onSuccessGetMovieDetail(movieDetail: response)
                
            } else {
                self.movieDetailService.delegateStruct = BaseWebServiceStruct(onStart: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.delegate?.onStartGetMovieDetail()
                    }, onSuccessObject: { [weak self] (response) in
                        guard let self = self else {
                            return
                        }
                        self.delegate?.onSuccessGetMovieDetail(movieDetail: response)
                    }, onFailed: { [weak self] (errorText) in
                        guard let self = self else {
                            return
                        }
                        self.delegate?.onFailedGetMovieDetail(errorText: errorText)
                })
                self.movieDetailService.request(RequestMovieDetail(i: imdbID))
            }
        }
    }
}

