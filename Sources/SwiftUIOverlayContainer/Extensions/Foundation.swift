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
    /// merge tapToDismiss between container and view
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

extension Array {
    mutating func push(_ element: Element, with animation: Animation? = nil) {
            self.append(element)
    }

    @discardableResult
    mutating func pop(with animation: Animation? = nil) -> Element? {
        guard self.count > 0 else { return nil }
        var result: Element?
        result = self.removeFirst()
        return result
    }
}

extension Array where Element == IdentifiableContainerView {
    mutating func remove(view id: UUID, with animation: Animation?) {
        guard let index = self.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(animation) {
            _ = self.remove(at: index)
        }
    }
}

func delayToRun(seconds: TimeInterval, perform action: @escaping () -> Void) {
    guard seconds > 0 else {
        action()
        return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        action()
    }
}
