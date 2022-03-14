//
//  ExtensionTests.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/10
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

@testable import SwiftUIOverlayContainer
import XCTest

class ExtensionTests: XCTestCase {
    func testArrayPush() throws {
        // given
        var queue = [3, 4, 5]
        let element = 10

        // when
        queue.push(element)

        // then
        XCTAssertEqual(queue.count, 4)
        XCTAssertEqual(queue.last, element)
    }

    func testArrayPop() throws {
        // given
        var queue = [3, 5, 6]

        // when
        let element = queue.pop()

        // then
        XCTAssertEqual(element, 3)
        XCTAssertEqual(queue.count, 2)
    }

    func testArrayPopQueueIsEmpty() throws {
        // given
        var queue: [Int] = []

        // when
        let element = queue.pop()

        // then
        XCTAssertNil(element)
        XCTAssertEqual(queue.count, 0)
    }
}

import SwiftUI

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
