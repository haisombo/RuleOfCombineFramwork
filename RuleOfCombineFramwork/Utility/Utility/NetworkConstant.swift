//
//  NetworkConstant.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation

public typealias StatusCode             = Int
public typealias RequestHeaders         = [String: String]

var kTimeoutInterval: TimeInterval              = 30.0
var kNetworkEnvironment: Environment            = .development   
var kRequestCachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
