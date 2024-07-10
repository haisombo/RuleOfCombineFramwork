//
//  NetworkManager.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation
import Combine

public protocol NetworkManagerProtocol: Any {
    var session: URLSession { get }
    func request<Route: Router>(_ route: Route) -> Future<Route.Response, Error>
}

public final class NetworkManager: NetworkManagerProtocol {
    public var session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    init(_ session: URLSession = .shared) {
        self.session = session
    }
    
    public convenience init(configuration: URLSessionConfiguration) {
        self.init()
        self.session = URLSession(configuration: configuration)
    }
    
    public func request<Route: Router>(_ route: Route) -> Future<Route.Response, Error> {
        return Future<Route.Response, Error> { [weak self] promise in
            guard let self = self else {
                print("Self is nil")
                return promise(.failure(RequestError.unknown()))
            }
            
            guard NetworkMonitor.shared.isReachable else {
                print("Network is not reachable")
                return promise(.failure(NetworkError.unreachable()))
            }
            
            guard let request = route.request() else {
                
                print("Invalid URL request")
                return promise(.failure(RequestError.invalidURL()))
            }
            
            NetworkLogger.r(
                        """
                        Request: \(request)
                        Header : \(String(describing: route.headers ))
                        Method : \(String(describing: route.method))
                        BODY   : \(String(describing:  route.body))
                        """)
            
            self.session.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    
                    if let response = response as? HTTPURLResponse, !response.statusCode.isSuccess {
                        
                        throw route.errorParser.parse(.mapRequestError(response.statusCode))
                    }
                    
                    let decodedDataString  = String(data: data, encoding: String.Encoding.utf8)?.removingPercentEncoding
                    guard let responseData = decodedDataString == nil ? data : decodedDataString?.data(using: .utf8) else {
                        let nsError = NSError(domain: "ClientError", code: 168, userInfo: [NSLocalizedDescriptionKey : "Could not convert string to data."])
#if DEBUG
                        print("""
                            \(nsError.code) | \(nsError.localizedDescription)
                            """)
#endif
                        promise(.failure(nsError))
                        throw nsError
                    }
#if DEBUG
                    NetworkLogger.s (
                                """
                                 Url Request    : \(request)
                                 DATA           : \(responseData.prettyPrinted)
                                """)
#endif
                    return data
                    
                }
                .decode(type: Route.Response.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        promise(.failure(route.errorParser.parse(.handleRequestError(error))))
                    }
                }, receiveValue: {
                    NetworkLogger.s($0 as AnyObject)
                    promise(.success($0)) })
                .store(in: &self.cancellables)
        }
    }
}
