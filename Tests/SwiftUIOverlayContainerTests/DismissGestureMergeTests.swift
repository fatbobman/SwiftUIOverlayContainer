//
//  DismissGestureMergeTests.swift
//
//
//  Created by Yang Xu on 2022/3/7
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import SwiftUI
@testable import SwiftUIOverlayContainer
import XCTest

class DismissGestureMergeTests: XCTestCase {
    func testMergeGestureWhenBothNil() throws {
        // given
        let containerGesture: ContainerViewDismissGesture? = nil
        let viewGesture: ContainerViewDismissGesture? = nil

        // when
        let result = ContainerViewDismissGesture.merge(containerGesture: containerGesture, viewGesture: viewGesture)

        // then
        switch result {
        case .disable:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testMergeGestureWhenContainerIsNil() throws {
        // given
        let containerGesture: ContainerViewDismissGesture? = nil
        let viewGesture: ContainerViewDismissGesture? = .tap

        // when
        let result = ContainerViewDismissGesture.merge(containerGesture: containerGesture, viewGesture: viewGesture)

        // then
        switch result {
        case .tap:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testMergeGestureWhenViewIsNil() throws {
        // given
        let containerGesture: ContainerViewDismissGesture? = .tap
        let viewGesture: ContainerViewDismissGesture? = nil

        // when
        let result = ContainerViewDismissGesture.merge(containerGesture: containerGesture, viewGesture: viewGesture)

        // then
        switch result {
        case .tap:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testMergeGestureWhenBothNotNil() throws {
        // given
        let containerGesture: ContainerViewDismissGesture? = .doubleTap
        let viewGesture: ContainerViewDismissGesture? = .tap

        // when
        let result = ContainerViewDismissGesture.merge(containerGesture: containerGesture, viewGesture: viewGesture)

        // then
        switch result {
        case .tap:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testMergeGestureWhenContainerIsNone() throws {
        // given
        let containerGesture: ContainerViewDismissGesture? = ContainerViewDismissGesture.disable
        let viewGesture: ContainerViewDismissGesture? = ContainerViewDismissGesture.disable

        // when
        let result = ContainerViewDismissGesture.merge(containerGesture: containerGesture, viewGesture: viewGesture)

        // then
        switch result {
        case .disable:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }
}
