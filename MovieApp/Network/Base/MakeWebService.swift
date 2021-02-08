//
//  MakeWebService.swift
//  EligashtCustomerApp
//
//  Created by Somaye Sabeti on 1/28/19.
//  Copyright © 2019 Somaye Sabeti. All rights reserved.
//

import Foundation

enum Urls {
    static let baseURL = "https://omdbapi.com/?apikey=4f588b70"
}

struct MakeWebService {
    let movieList = WebServiceMethod<RequestMovieList, ResponseMovieList>(url: Urls.baseURL , requestType: .query)
    let movieDetail = WebServiceMethod<RequestMovieDetail, ResponseMovieDetail>(url: Urls.baseURL , requestType: .query)
}
