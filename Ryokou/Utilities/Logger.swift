//
//  Logger.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/28/25.
//

import Foundation
import os

enum Log {
    static func d(_ tag: String, _ msg: String, file: StaticString = #fileID, line: Int = #line) {
        Logger(subsystem: Bundle.main.bundleIdentifier!, category: tag)
            .debug("[\(file):\(line)] \(msg)")
    }
    
    static func i(_ tag: String, _ msg: String) {
        Logger(subsystem: Bundle.main.bundleIdentifier!, category: tag).info("\(msg)")
    }
    
    static func e(_ tag: String, _ msg: String) {
        Logger(subsystem: Bundle.main.bundleIdentifier!, category: tag).error("\(msg)")
    }
}
