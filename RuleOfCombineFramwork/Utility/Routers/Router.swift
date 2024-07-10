//
//  Router.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation

public protocol Router {
    associatedtype Response: Decodable
    var url             : String { get }
    var path            : String { get }
    var method          : HTTPMethod { get }
    var headers         : RequestHeaders? { get }
    var requiresAuth    : Bool { get }
    var requestType     : RequestType { get }
    var pathParameters  : [String] { get }
    var errorParser     : ErrorParserType { get }
    var body            : Encodable? { get } // Updated to use Encodable for the request body

}

extension Router {
    var url             : String { return kNetworkEnvironment.url }
    var requiresAuth    : Bool { return true }
    var method          : HTTPMethod { return .get }
    var pathParameters  : [String] { return [] }
    var errorParser     : ErrorParserType { return ErrorParser()}
    var headers         : RequestHeaders? {
        return [
            HTTPHeaderField.acceptType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue
        ]
    }
}

public enum RequestType {
    case data
    case download
    case upload
}
public enum ResponseType {
    case json
    case file
}
