//
//  HTTPHeaderField.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation

enum HTTPHeaderField: String {
    
    case acceptType         = "Accept"
    case contentType        = "Content-Type"
    case authentication     = "Authorization"
    case acceptEncoding     = "Accept-Encoding"
    
}

enum ContentType: String {
    
    case json       = "application/json"
    case formData   = "multipart/form-data; boundary="
    
}
