//
//  StatusCode+Helper.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation

extension StatusCode {
    
    var isSuccess: Bool {
        (200..<300).contains(self)
    }
    
}
