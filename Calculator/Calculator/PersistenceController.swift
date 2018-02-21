//
//  PersistenceController.swift
//  Calculator
//
//  Created by Christopher Thiebaut on 2/21/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import Foundation

class PersistenceController {
    
    private enum StorageKeys: String {
        case screenValue
        case storedValue1
        case storedValue2
    }
    
    private init(){} //All functions of this class are static, so no one should try to instantiate it.  That would be dumb.
    
    private static func fileURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileName = "storedValues.json"
        let fullURL = urls[0].appendingPathComponent(fileName)
        return fullURL
    }
    
    static func save(values: (screen: Double?,storedValue1: Double?,storedValue2: Double?)){
        var dictionary: [String:Double?] = [:]
        dictionary.updateValue(values.screen, forKey: StorageKeys.screenValue.rawValue)
        dictionary.updateValue(values.storedValue1, forKey: StorageKeys.storedValue1.rawValue)
        dictionary.updateValue(values.storedValue2, forKey: StorageKeys.storedValue2.rawValue)
        do {
            let jsonData = try JSONEncoder().encode(dictionary)
            try jsonData.write(to: fileURL())
        } catch let error {
            NSLog("Error saving calculator state: \(error.localizedDescription)")
        }
    }
    
    static func loadValues() -> (screen: Double?, storedValue1: Double?, storedValue2: Double?)? {
        var values: (screen: Double?, storedValue1: Double?, storedValue2: Double?) = (0,0,0)
        var dictionary: [String: Double]
        do {
            let data = try Data.init(contentsOf: fileURL())
            dictionary = try JSONDecoder().decode([String:Double].self, from: data)
            
        } catch let error {
            NSLog("Cannot retrieve calculator state due to error: \(error.localizedDescription)")
            return nil
        }
        
        values.screen = dictionary[StorageKeys.screenValue.rawValue]
        values.storedValue1 = dictionary[StorageKeys.storedValue1.rawValue]
        values.storedValue2 = dictionary[StorageKeys.storedValue2.rawValue]
        return values
    }
}

