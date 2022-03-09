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

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1000000000))
    }
}

extension Bool {
    static func merge(containerTapToDismiss: Self?, viewTapToDismiss: Self?, containerType: ContainerViewDisplayType) -> Self {
        if containerTapToDismiss == nil, viewTapToDismiss == nil { return false }
        switch containerType {
        case .horizontal, .vertical:
            return containerTapToDismiss ?? false
        case .stacking:
            return viewTapToDismiss ?? containerTapToDismiss ?? false
        }
    }
}
