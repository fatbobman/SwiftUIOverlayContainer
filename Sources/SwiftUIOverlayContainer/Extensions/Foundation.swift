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
import SwiftUI

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1000000000))
    }
}

extension Bool {
    /// Merge tapToDismiss between the configuration of container and the configuration of container view
    ///
    /// in stacking : view's priority is higher then container
    /// in horizontal & vertical: view's tapToDismiss will be ignored
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

/// Delay execution of closure on a specified dispatch queue
@MainActor
func delayToRun(seconds: TimeInterval, in dispatchQueue: DispatchQueue = .main, perform action: @escaping @MainActor () -> Void) async {
    guard seconds > 0 else {
        action()
        return
    }
    try? await Task.sleep(seconds: seconds)
    action()
}
