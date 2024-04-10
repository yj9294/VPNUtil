//
//  File.swift
//  
//
//  Created by Super on 2024/4/9.
//

import Foundation
@propertyWrapper
public struct UserDefault<T: Codable> {
    public var value: T?
    public let key: String
    public init(key: String) {
        self.key = key
        self.value = UserDefaults.standard.getObject(T.self, forKey: key)
    }
    
    public var wrappedValue: T? {
        set  {
            value = newValue
            UserDefaults.standard.setObject(value, forKey: key)
            UserDefaults.standard.synchronize()
        }
        
        get { value }
    }
}


extension UserDefaults {
    public func setObject<T: Codable>(_ object: T?, forKey key: String) {
        let encoder = JSONEncoder()
        guard let object = object else {
            TBALog("[US] object is nil.")
            if self.object(forKey: key) != nil {
                self.removeObject(forKey: key)
            }
            return
        }
        guard let encoded = try? encoder.encode(object) else {
            TBALog("[US] encoding error.")
            return
        }
        self.setValue(encoded, forKey: key)
    }
    
    public func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else {
            TBALog("[US] data is nil for \(key).")
            return nil
        }
        guard let object = try? JSONDecoder().decode(type, from: data) else {
            TBALog("[US] decoding error.")
            return nil
        }
        return object
    }
}
