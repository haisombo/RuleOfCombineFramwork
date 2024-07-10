//
//  NetworkMonitor.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import Foundation
import Network

final class NetworkMonitor {

    // MARK: - Properties
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private var status = NWPath.Status.requiresConnection
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    public var isCellular: Bool = true
    public var isReachable: Bool {
        queue.sync {
            status == .satisfied
        }
    }

    // MARK: - Private Initializer
    private init() {
        startMonitoring()
    }

    // MARK: - Monitor Network Connection
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.queue.sync {
                self.status = path.status
                self.isCellular = path.isExpensive
            }

            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    print("We're connected over WiFi!")
                } else if path.usesInterfaceType(.cellular) {
                    print("We're connected over Cellular!")
                } else {
                    print("We're connected over other network!")
                }
            } else {
                print("No connection.")
                // Post disconnected notification if needed
            }
        }
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }
}
