//
//  LogInRequest.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation

struct LogInRequest : Router {
    
    typealias Response              = [Login.Response]
    var method                      : HTTPMethod = .post
    
//    var parameters                  : RequestParameters?
    var body: Encodable?
    var requestType                 : RequestType = .data
    var path: String                = EndPoint.login.rawValue
    
}
