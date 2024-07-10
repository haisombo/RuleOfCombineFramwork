//
//  LogInVM.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation
import Combine

class LogInViewModel {
    
    // MARK: - Properties
    private var logInResponse: [Login.Response]?
    private var subscriptions = Set<AnyCancellable>()
    private let networkManager: NetworkManagerProtocol
    private let output: PassthroughSubject<Output, Never> = .init()
    
    var autoLogin: Bool?
    var corpGroupCode: String?
    var userId: String?
    var password: String?

    // MARK: - Enumerations
    enum Input: Equatable {
        case load
        case refresh
    }

    enum Output {
        case fetchUserDidFinish
        case fetchUserDidFail(error: Error)
        case fetchUserDidSuccess(user: [Login.Response])
    }
    
    // MARK: - Initializer
    init(_ networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    private func requestAuth(autoLogin: Bool, corpGroupCode: String, userId: String, password: String) {
        let body = Login.Request(autoLogin: autoLogin, corpGroupCode: corpGroupCode, userId: userId, password: password)
        
        let request = LogInRequest(body: body)
        
        networkManager.request(request)
            .sink { completionHandler in
                switch completionHandler {
                case .failure(let error):
                    self.output.send(.fetchUserDidFail(error: error))
                case .finished:
                    self.output.send(.fetchUserDidFinish)
                }
            } receiveValue: { [weak self] dataResponse in
                self?.logInResponse = dataResponse
                self?.output.send(.fetchUserDidSuccess(user: dataResponse))
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Response Defined Context Methods
extension LogInViewModel {
    /** internal allows use from any source file  in the defining module but not from outside that module.
     This is generally the default access level.
     */
    internal func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        
        input.sink { [weak self] event in
            switch event {
            case .load, .refresh:
                
                guard let self = self else { return }
                self.requestAuth(autoLogin      : self.autoLogin ?? false,
                                 corpGroupCode  : self.corpGroupCode ?? "" ,
                                 userId         : self.userId ?? "" ,
                                 password       : self.password ?? "" )
            }
        }.store(in: &subscriptions)
        
        return output.eraseToAnyPublisher()
    }
    
    internal func logInResponse(_ responseData : Login.Response ) -> Login.Response? {
        let response = self.logInResponse?.filter({$0.status == responseData.status  })
        return response?.first
    }
}
