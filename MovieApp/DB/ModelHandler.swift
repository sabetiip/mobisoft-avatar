//
//  ModelHandler.swift
//  MovieApp
//
//  Created by Somaye Sabeti on 2/4/18.
//  Copyright © 2018 Somaye Sabeti. All rights reserved.
//

import Foundation
import CoreData

class ModelHandler {
    
    private static let coreDataStack = CoreDataStack(modelName: "MovieApp")
    
    // MARK: - Add Or Update Object CoreData
    class func addMovieList(movieList: [ResponseMovieDetail]) {
        for movie in movieList {
            
            var newMovie : MovieDBObj!
            coreDataStack.mainQueueContext.performAndWait() {
                newMovie = NSEntityDescription.insertNewObject(forEntityName: "MovieDBObj",
                                                               into: coreDataStack.mainQueueContext) as? MovieDBObj
                newMovie.imdbID = movie.imdbID
                newMovie.title = movie.Title
                newMovie.year = movie.Year
                newMovie.rated = movie.Rated
                newMovie.runtime = movie.Runtime
                newMovie.genre = movie.Genre
                newMovie.director = movie.Director
                newMovie.writer = movie.Writer
                newMovie.actors = movie.Actors
                newMovie.plot = movie.Plot
                newMovie.poster = movie.Poster
                newMovie.metascore = movie.Metascore
                newMovie.imdbRating = movie.imdbRating
                newMovie.imdbVotes = movie.imdbVotes
                newMovie.type = movie.`Type`
                
                do {
                    try coreDataStack.saveChanges()
                }
                catch let error {
                    print("\(error)")
                }
            }
        }
    }
    
    class func fetchMovie(imdbID: String, completion: @escaping (MovieDBObj?) -> Void) {
        
        let fetchRequest: NSFetchRequest<MovieDBObj> = MovieDBObj.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(MovieDBObj.imdbID)) == '\(imdbID)'")
        fetchRequest.predicate = predicate

        let mainQueueContext = coreDataStack.mainQueueContext
        var fetchedMovies: [MovieDBObj]?
        mainQueueContext.performAndWait {
            fetchedMovies = try! mainQueueContext.fetch(fetchRequest)
            if let movieEntity = fetchedMovies?.last {
                completion(movieEntity)
            } else {
                completion(nil)
            }
        }
    }
    
    class func fetchMovieList(completion: @escaping ([MovieDBObj]?) -> Void) {
        let fetchRequest: NSFetchRequest<MovieDBObj> = MovieDBObj.fetchRequest()
        let mainQueueContext = coreDataStack.mainQueueContext
        var fetchedMovies: [MovieDBObj]?
        mainQueueContext.performAndWait {
            fetchedMovies = try! mainQueueContext.fetch(fetchRequest)
            if let movieList = fetchedMovies, !movieList.isEmpty {
                completion(movieList)
            } else {
                completion(nil)
            }
        }
    }
    
    class func updateMovie(movieDetail: ResponseMovieDetail) {
        guard let imdbID = movieDetail.imdbID else { return }
        
        fetchMovie(imdbID: imdbID) { (movieDBObj) in
            if let movieDBObj = movieDBObj {
                let movieDBObjManagedObject = movieDBObj as NSManagedObject
                movieDBObjManagedObject.setValue(movieDetail.Rated, forKey: "rated")
                movieDBObjManagedObject.setValue(movieDetail.imdbRating, forKey: "imdbRating")
                movieDBObjManagedObject.setValue(movieDetail.imdbVotes, forKey: "imdbVotes")
                movieDBObjManagedObject.setValue(movieDetail.Runtime, forKey: "runtime")
                movieDBObjManagedObject.setValue(movieDetail.Plot, forKey: "plot")
                movieDBObjManagedObject.setValue(movieDetail.Writer, forKey: "writer")
                movieDBObjManagedObject.setValue(movieDetail.Director, forKey: "director")
                movieDBObjManagedObject.setValue(movieDetail.Actors, forKey: "actors")
                movieDBObjManagedObject.setValue(movieDetail.Genre, forKey: "genre")
                movieDBObjManagedObject.setValue(movieDetail.Metascore, forKey: "metascore")
                movieDBObjManagedObject.setValue(movieDetail.Type, forKey: "type")
                do {
                    try coreDataStack.saveChanges()
                } catch let error {
                    print("\(error)")
                }
            }
        }
    }
    
    class func deleteAllMovies() {
        let fetchRequest: NSFetchRequest<MovieDBObj> = MovieDBObj.fetchRequest()
        let mainQueueContext = coreDataStack.mainQueueContext
        var fetchedMovies: [MovieDBObj]?
        mainQueueContext.performAndWait {
            fetchedMovies = try! mainQueueContext.fetch(fetchRequest)
            if let movieEntitys = fetchedMovies {
                for movie in movieEntitys {
                    mainQueueContext.delete(movie)
                }
                do {
                    try coreDataStack.saveChanges()
                }
                catch let error {
                    print("\(error)")
                }
            }
        }
    }
}
