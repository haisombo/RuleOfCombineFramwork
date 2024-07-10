//
//  Environment.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation


public enum Environment: String, CaseIterable {
    
    case development
    case staging
    case production
}

extension Environment {
    
    public var url: String {
        switch self {
            
        case .development:
            return "https://next-dev.bizplay.biz/api/v2/auth"
        case .staging:
            return "https://next-dev.bizplay.biz/api/v2/auth"
        case .production:
            return "https://next-dev.bizplay.biz/api/v2/auth"
        }
    }
}
