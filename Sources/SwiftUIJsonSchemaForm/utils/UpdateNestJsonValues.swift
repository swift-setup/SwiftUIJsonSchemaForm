//
//  File.swift
//
//
//  Created by Qiwei Li on 1/27/23.
//

import Foundation
import SwiftyJSON

func updateValueHelper(value: Any, key: String, values: JSON) -> JSON {
    var newValues = values
    newValues[key] = JSON(rawValue: value)!
    return newValues
}
