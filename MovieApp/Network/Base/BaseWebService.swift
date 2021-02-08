//
//  BaseWebService.swift
//  EligashtCustomerApp
//
//  Created by Somaye Sabeti on 11/22/18.
//  Copyright © 2018 Somaye Sabeti. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

enum ErrorType: String {
    
    case ErrorOnCodable = "ErrorOnCodable";
    case ErrorOnNetwork = "ErrorOnNetwork";
    case ErrorOnGetDataFromServer = "ErrorOnGetDataFromServer";
    case ErrorOnResponse = "ErrorOnResponse";
}

protocol BaseWebServiceDelegate {
    func onRequestStart() -> Void
    func onRequestSuccess<TYPE_RESPONSE>(_ response: TYPE_RESPONSE) -> Void
    func onRequestSuccess<TYPE_RESPONSE>(_ response: [TYPE_RESPONSE]) -> Void
    func onRequestSuccess(_ response: String) -> Void
    func onRequestSuccess(_ response: Data) -> Void
    func onRequestFailed(_ description: String) -> Void
}

struct BaseWebServiceStruct<TYPE_RESPONSE: Codable> {
    var onStart: () -> Void
    var onSuccessObject: (_ response: TYPE_RESPONSE) -> Void
    var onSuccessArray: (_ response: [TYPE_RESPONSE]) -> Void
    var onSuccessText: (_ response: String) -> Void
    var onSuccessData: (_ response: Data, _ fileUrl: URL?) -> Void
    var onFailed: (_ description: String) -> Void
    
    init(onStart: @escaping () -> Void = {}, onSuccessObject: @escaping (_ response: TYPE_RESPONSE) -> Void = {_ in }, onSuccessArray: @escaping (_ response: [TYPE_RESPONSE]) -> Void = {_ in }, onSuccessText: @escaping (_ response: String) -> Void = {_ in }, onSuccessData: @escaping (_ response: Data, _ fileUrl: URL?) -> Void = {_,_  in }, onFailed: @escaping (_ description: String) -> Void = {_  in }) {
        self.onStart = onStart
        self.onSuccessObject = onSuccessObject
        self.onSuccessArray = onSuccessArray
        self.onSuccessText = onSuccessText
        self.onSuccessData = onSuccessData
        self.onFailed = onFailed
    }
}

private enum LoadingStatus {
    case loading, success, failed
}

class BaseWebService<TYPE_REQUEST: Codable, TYPE_RESPONSE: Codable> {
    
    var webServiceMethod: WebServiceMethod<TYPE_REQUEST, TYPE_RESPONSE>
    
    var currentRequestObject: TYPE_REQUEST?
    var isRefreshing = false
    private var currentRequestString: String?
    
    var delegateStruct: BaseWebServiceStruct<TYPE_RESPONSE>?
    
    //MARK: Initialize
    init(webServiceMethod: WebServiceMethod<TYPE_REQUEST, TYPE_RESPONSE>) {
        self.webServiceMethod = webServiceMethod
    }
    
    //MARK: Helpers
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    private func getURLQuery() -> String {
        guard let requestMappable = self.currentRequestObject,
            let requestDictionary = requestMappable.dictionary
            else { return "" }
        
        var query = ""
        for (key, value) in requestDictionary {
            query += "&\(key)=\(value)"
        }
        
        return query
    }
    
    public func getURLRequest<T: Codable>(_ jsonObject: T? = nil) -> URLRequest {
        var mutableUrlRequest: URLRequest!
        var url = webServiceMethod.url
        
        switch webServiceMethod.requestType {
        case .jsonObject:
            mutableUrlRequest = URLRequest(url: URL(string: url)!)
            if let jsonObject = jsonObject {
                do {
                    let encoded = try JSONEncoder().encode(jsonObject)
                    let jsonRequest = String(data: encoded, encoding: .utf8)!
                    debugPrint("Body is:\(jsonRequest)")
                    mutableUrlRequest.httpBody = encoded
                    
                } catch {
                    self.onFail(errorType: .ErrorOnCodable)
                }
            }
            
        case .jsonQuery:
            mutableUrlRequest = URLRequest(url: URL(string: url)!)
            
            var str = getURLQuery()
            str = String(str.dropFirst())
            mutableUrlRequest.httpBody = str.data(using: .utf8)
            
        case .query:
            url += getURLQuery()
            mutableUrlRequest = URLRequest(url: URL(string: url)!)
        }
        
        debugPrint("Request is:", "Url is: \(url)", separator: "\n")
        
        mutableUrlRequest.httpMethod = webServiceMethod.httpMethod.rawValue
        for (key, value) in webServiceMethod.params {
            mutableUrlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return mutableUrlRequest
    }
    
    open func request(_ object: TYPE_REQUEST? = nil, string: String? = nil) {
        
        guard isConnectedToNetwork() else {
            self.onFail(errorType: .ErrorOnNetwork)
            return
        }
        
        self.currentRequestObject = object
        self.currentRequestString = string
        onStart()
        
        let urlRequest = getURLRequest(object)
        
        let manager = Alamofire.SessionManager.default
        let request: DataRequest = manager.request(urlRequest)
        
        switch webServiceMethod.responseType {
        case .jsonObject:
            
            request.response { [weak self] (response) in
                guard let self = self else { return }
                
                debugPrint("Get Response From Server")
                
                guard let statusCode = response.response?.statusCode else {
                    self.onFail(errorType: .ErrorOnGetDataFromServer)
                    return
                }
                
                if statusCode != self.webServiceMethod.successStatusCode {
                    
                    print("StatusCode Of Response Server: \(statusCode)")
                    print(String(data: response.data!, encoding: .utf8)!)
                    self.onFail(errorType: .ErrorOnGetDataFromServer)
                    
                } else {
                    if let responseString = String(data: response.data!, encoding: .utf8), let responseData = responseString.data(using: .utf8) {
                        debugPrint("Response is:", "\(String(data: responseData, encoding: .utf8)!)", separator: "\n")
                        do {
                            let responseValue: TYPE_RESPONSE = try JSONDecoder().decode(TYPE_RESPONSE.self, from: responseData)
                            self.onSuccess(responseValue, allHeaderFields: response.response?.allHeaderFields as? [String: String])
                        } catch {
                            debugPrint("Error on mapping")
                            self.onFail(errorType: .ErrorOnCodable)
                        }
                    }
                }
            }
            
        default:
            break
        }
    }
    
    //MARK: Callbacks
    open func onStart() {
        delegateStruct?.onStart()
    }
    
    open func onSuccess(_ response: TYPE_RESPONSE, allHeaderFields: [String: String]?) {
        delegateStruct?.onSuccessObject(response)
    }
    
    open func onSuccess(_ response: [TYPE_RESPONSE], allHeaderFields: [String: String]?) {
        delegateStruct?.onSuccessArray(response)
    }
    
    open func onSuccess(_ response: String, allHeaderFields: [String: String]?) {
        delegateStruct?.onSuccessText(response)
    }
    
    open func onSuccess(_ response: Data, fileUrl: URL? = nil) {
        delegateStruct?.onSuccessData(response, fileUrl)
    }
    
    func onFail(errorType: ErrorType) {
        delegateStruct?.onFailed(errorType.rawValue)
    }
}

