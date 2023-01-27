//
//  File.swift
//  
//
//  Created by Qiwei Li on 1/27/23.
//

import Foundation
import SwiftyJSON


func updateValueHelper(value: JSON, keys: [String], values: JSON) -> JSON {
    let key = keys.first!
    var newValues = values
    if keys.count == 1 {
        newValues[key] = value
        return newValues
    }

    newValues[key] = updateValueHelper(value: value, keys: Array(keys.dropFirst()), values: values[key])
    return newValues
}
