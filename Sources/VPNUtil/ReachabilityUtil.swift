//
//  File.swift
//  
//
//  Created by Super on 2024/4/9.
//

import Foundation
import Foundation
import Reachability

public class ReachabilityUtil {
    public static let shared = ReachabilityUtil()

    private let reachability = try! Reachability()
    
    public var networkUpdated: ((Bool)->Void)? = nil
    
    public var isConnected: Bool = false

    private init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    public func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(_:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        isConnected = reachability.connection != .unavailable
    }

    public func stopMonitoring() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }

    @objc private func networkChanged(_ notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }

        if reachability.connection != .unavailable {
            print("网络已连接")
            self.networkUpdated?(true)
            self.isConnected = true
        } else {
            self.networkUpdated?(false)
            print("网络已断开")
            self.isConnected = false
        }
    }
}
