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
    func testShadowMergeWhenContainerIsNilAndContainerTypeIsX() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = nil
        let viewShadow: ContainerViewShadowStyle? = .radius(10)
        let containerType = ContainerType.x

        // when
        let result = ContainerViewShadowStyle.merge(containerShadow: containerShadow, viewShadow: viewShadow, containerType: containerType)

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testShadowMergeWhenContainerIsNilAndContainerTypeIsZ() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = nil
        let viewShadow: ContainerViewShadowStyle? = .radius(10)
        let containerType = ContainerType.z

        // when
        let result = ContainerViewShadowStyle.merge(containerShadow: containerShadow, viewShadow: viewShadow, containerType: containerType)

        // then
        switch result {
        case .radius:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testShadowMergeWhenViewIsNoneAndContainerTypeIsY() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = .radius(20)
        let viewShadow: ContainerViewShadowStyle? = ContainerViewShadowStyle.none
        let containerType = ContainerType.y

        // when
        let result = ContainerViewShadowStyle.merge(containerShadow: containerShadow, viewShadow: viewShadow, containerType: containerType)

        // then
        switch result {
        case .radius:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testShadowMergeWhenBothNotNilAndContainerTypeIsX() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = .radius(20)
        let viewShadow: ContainerViewShadowStyle? = .radius(10)
        let containerType = ContainerType.x

        // when
        let result = ContainerViewShadowStyle.merge(containerShadow: containerShadow, viewShadow: viewShadow, containerType: containerType)

        // then
        switch result {
        case .radius(let radius):
            XCTAssertEqual(radius, 20)
        default:
            XCTAssert(false)
        }
    }

    func testShadowMergeWhenBothNotNilAndContainerTypeIsZ() throws {
        // given
        let containerShadow: ContainerViewShadowStyle? = .radius(20)
        let viewShadow: ContainerViewShadowStyle? = .radius(10)
        let containerType = ContainerType.z

        // when
        let result = ContainerViewShadowStyle.merge(containerShadow: containerShadow, viewShadow: viewShadow, containerType: containerType)

        // then
        switch result {
        case .radius(let radius):
            XCTAssertEqual(radius, 10)
        default:
            XCTAssert(false)
        }
    }
}
