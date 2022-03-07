//
//  File.swift
//
//
//  Created by Yang Xu on 2022/3/7
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation

/// Protocol for Logger
public protocol SwiftUIOverlayContainerLoggerProtocol {
    func log(type: SwiftUIOverlayContainerLogType, message: String)
}


/// Log Type
public enum SwiftUIOverlayContainerLogType: String {
    case debug, info, notice, error, fault
}

extension SwiftUIOverlayContainerLoggerProtocol {
    func log(type: SwiftUIOverlayContainerLogType, message: String) {
        print("[\(type.rawValue)] : \(message)")
    }
}
