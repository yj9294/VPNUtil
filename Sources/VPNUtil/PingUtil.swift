//
//  File.swift
//  
//
//  Created by Super on 2024/4/9.
//

import Foundation

class PingUtil: NSObject {
    public static let shared = PingUtil()
    
    func pingAllServers(serverList: [VPNCountry], completion: (([VPNCountry]?) -> Void)?) {
        var pingResult = [Int : [Double]]()
        if serverList.count == 0 {
            completion?(nil)
            return
        }
        var pingUtilDict = [Int : VPNPingUtil?]()


        let group = DispatchGroup()
        let queue = DispatchQueue.main
        for (index, server) in serverList.enumerated() {
            if server.ip.count == 0 {
                continue
            }
            group.enter()
            queue.async {
                pingUtilDict[index] = VPNPingUtil.startPing(hostName: server.ip, count: 3, pingCallback: { pingItem in
                    switch pingItem.status! {
                        case .start:
                            pingResult[index] = []
                            break
                        case .failToSendPacket:
                            group.leave()
                            break
                        case .receivePacket:
                            pingResult[index]?.append(pingItem.singleTime!)
                        case .receiveUnpectedPacket:
                            break
                        case .timeout:
                            pingResult[index]?.append(1000.0)
                            group.leave()
                        case .error:
                            group.leave()
                        case .finished:
                            pingUtilDict[index] = nil
                            group.leave()
                    }
                })
            }
        }
        group.notify(queue: DispatchQueue.main) {
            var pingAvgResult = [Int : Double]()
            pingResult.forEach {
                if $0.value.count > 0 {
                    let sum = $0.value.reduce(0, +)
                    let avg = Double(sum) / Double($0.value.count)
                    pingAvgResult[$0.key] = avg
                }
            }

            if pingAvgResult.count == 0 {
                NSLog("[ERROR] ping error")
                completion?(nil)
                return
            }

            var serverList = serverList

            pingAvgResult.forEach {
                serverList[$0.key].delay = $0.value
            }

            serverList = serverList.filter {
                return ($0.delay ?? 0) > 0
            }

            serverList = serverList.sorted(by: { return ($0.delay ?? 0) < ($1.delay ?? 0) })

            serverList.forEach {
                NSLog("[IP] \($0.country)-\($0.city)-\($0.ip)-\(String(format: "%.2f", $0.delay ?? 0 ))ms")
            }

            completion?(serverList)
        }
    }
}
