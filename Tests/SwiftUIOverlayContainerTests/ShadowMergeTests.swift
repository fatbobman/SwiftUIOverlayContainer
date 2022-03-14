//
//  ShadowMergeTests.swift
//
//
//  Created by Yang Xu on 2022/3/7
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

@testable import SwiftUIOverlayContainer
import XCTest

class ShadowMergeTests: XCTestCase {
    func testShadowMergeWhenContainerIsNilAndContainerViewDisplayTypeIsX() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = nil
        let viewShadow: ContainerViewShadowStyle? = .radius(10)
        let containerViewDisplayType = ContainerViewDisplayType.horizontal

        // when
        let result = ContainerViewShadowStyle.merge(
            containerShadow: containerShadow,
            viewShadow: viewShadow,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .disable:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testShadowMergeWhenContainerIsNilAndContainerViewDisplayTypeIsZ() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = nil
        let viewShadow: ContainerViewShadowStyle? = .radius(10)
        let containerViewDisplayType = ContainerViewDisplayType.stacking

        // when
        let result = ContainerViewShadowStyle.merge(
            containerShadow: containerShadow,
            viewShadow: viewShadow,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .radius:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testShadowMergeWhenViewIsNoneAndContainerViewDisplayTypeIsY() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = .radius(20)
        let viewShadow: ContainerViewShadowStyle? = ContainerViewShadowStyle.disable
        let containerViewDisplayType = ContainerViewDisplayType.vertical

        // when
        let result = ContainerViewShadowStyle.merge(
            containerShadow: containerShadow,
            viewShadow: viewShadow,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .radius:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testShadowMergeWhenBothNotNilAndContainerViewDisplayTypeIsX() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = .radius(20)
        let viewShadow: ContainerViewShadowStyle? = .radius(10)
        let containerViewDisplayType = ContainerViewDisplayType.horizontal

        // when
        let result = ContainerViewShadowStyle.merge(
            containerShadow: containerShadow,
            viewShadow: viewShadow,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .radius(let radius):
            XCTAssertEqual(radius, 20)
        default:
            XCTAssert(false)
        }
    }

    func testShadowMergeWhenBothNotNilAndContainerViewDisplayTypeIsZ() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = .radius(20)
        let viewShadow: ContainerViewShadowStyle? = .radius(10)
        let containerViewDisplayType = ContainerViewDisplayType.stacking

        // when
        let result = ContainerViewShadowStyle.merge(
            containerShadow: containerShadow,
            viewShadow: viewShadow,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .radius(let radius):
            XCTAssertEqual(radius, 10)
        default:
            XCTAssert(false)
        }
    }
}
