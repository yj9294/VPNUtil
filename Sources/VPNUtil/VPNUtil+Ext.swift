//
//  File.swift
//  
//
//  Created by Super on 2024/4/9.
//

import Foundation

extension VPNUtil {
    public func loadPermiss(_ present: (()->Void)? = nil, ok: (()->Void)? = nil, deny: (()->Void)? = nil, continueHandle: (()->Void)? = nil) {
        if managerState == .idle || managerState == .error {
            vpnPermission = true
            present?()
            VPNUtil.shared.create { err in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.vpnPermission = false
                }
                if let err = err {
                    VPNLog("[VPN] err:\(err.localizedDescription)")
                    deny?()
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ok?()
                    continueHandle?()
                }
            }
        } else {
            vpnPermission = true
            continueHandle?()
        }
    }
    
    public func pingServer(connectBegin:(()->Void)? = nil, connectResult: ((Bool, String?)->Void)? = nil) {
        if !ReachabilityUtil.shared.isConnected {
            connectResult?(false, "Local network is not turned on.")
            return
        }
        
        connectBegin?()
        if AppUtil.shared.getVPNCountry.isSmart {
            pingAllServers(serverList:AppUtil.shared.getVPNCountryList.allModels()) { serverList in
                guard let serverList = serverList, !serverList.isEmpty else {
                    connectResult?(false, ""Try it agin.")
                    return
                }
                if let country = VPNCountryList.smartModel(with: serverList) {
                    AppUtil.shared.vpnConnectCountry = country
                    self.doConnect(country)
                } else {
                    connectResult?(false, ""Try it agin.")
                }
            }
        } else {
            pingAllServers(serverList: [AppUtil.shared.getVPNConnectCountry]) { serverList in
                if let country = serverList?.first {
                    self.doConnect(country)
                }
            }
        }
    }
}
