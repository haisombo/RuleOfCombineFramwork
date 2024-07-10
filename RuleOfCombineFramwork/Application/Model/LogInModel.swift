//
//  LogInModel.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation

// Login Model API
struct Login {
    
    struct Request          :  Codable   {
        
        let autoLogin       : Bool?
        let corpGroupCode   : String?
        let userId          : String?
        let password        : String?
  
    }
    
    struct Response : Codable {
        
        let code       : String?
        let message    : String?
        let status     : Int?
        let errorCode  : String?
        let errors     : [Errors]?
        
        struct Errors : Codable    {
            let field : String?
            let value : String?
            let reason : String?
        }
    }
}
