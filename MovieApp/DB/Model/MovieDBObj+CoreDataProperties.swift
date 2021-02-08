//
//  MovieDBObj+CoreDataProperties.swift
//  MovieApp
//
//  Created by Somayeh Sabeti on 2/8/21.
//  Copyright © 2021 Somayeh Sabeti. All rights reserved.
//
//

import Foundation
import CoreData


extension MovieDBObj {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieDBObj> {
        return NSFetchRequest<MovieDBObj>(entityName: "MovieDBObj")
    }

    @NSManaged public var title: String?
    @NSManaged public var year: String?
    @NSManaged public var rated: String?
    @NSManaged public var poster: String?
    @NSManaged public var imdbRating: String?
    @NSManaged public var imdbVotes: String?
    @NSManaged public var runtime: String?
    @NSManaged public var plot: String?
    @NSManaged public var writer: String?
    @NSManaged public var director: String?
    @NSManaged public var actors: String?
    @NSManaged public var genre: String?
    @NSManaged public var imdbID: String?
    @NSManaged public var metascore: String?
    @NSManaged public var type: String?
}
