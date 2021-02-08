//
//  WebServiceMethod.swift
//  EligashtCustomerApp
//
//  Created by Somaye Sabeti on 11/22/18.
//  Copyright © 2018 Somaye Sabeti. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

public enum ResponseType {
    case text, data, jsonObject, jsonArray, rawArray
}

public enum RequestType {
    case jsonObject, query, jsonQuery
}

class WebServiceMethod<TYPE_REQUEST: Codable, TYPE_RESPONSE: Codable> {
    
    public let url: String
    public let httpMethod: HTTPMethod
    public let successStatusCode: Int
    public let responseType: ResponseType
    public let requestType: RequestType
    public let setSession: Bool
    public var params: [String: String]
    
    init(url: String,
         httpMethod: HTTPMethod = .post,
         successStatusCode: Int = 200,
         responseType: ResponseType = .jsonObject,
         requestType: RequestType = .jsonObject,
         setSession: Bool = true,
         params: [String: String] = [
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"]) {
        
        self.url = url
        self.httpMethod = httpMethod
        self.successStatusCode = successStatusCode
        self.responseType = responseType
        self.requestType = requestType
        self.setSession = setSession
        self.params = params
    }
    
}
