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
@testable import SwiftUIOverlayContainer
import XCTest

class BackgroundMergeTests: XCTestCase {
    func testBackgroundMergeWhenBothNilAndContainerTypeIsX() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = nil
        let containerType: ContainerType = .x

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenBothNilAndContainerTypeIsZ() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = nil
        let containerType: ContainerType = .z

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenContainerIsNilAndContainerTypeIsX() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerType: ContainerType = .x

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenContainerIsNilAndContainerTypeIsZ() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerType: ContainerType = .z

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .blur:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenContainerIsNilAndContainerTypeIsY() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerType: ContainerType = .y

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenBothNotNilAndContainerTypeIsX() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = .color(.red)
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerType: ContainerType = .x

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .color:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenBothNotNilAndContainerTypeIsY() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = .color(.red)
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerType: ContainerType = .y

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .color:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenBothNotNilAndContainerTypeIsZ() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = .color(.red)
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerType: ContainerType = .z

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .blur:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenViewIsNoneAndContainerTypeIsZ() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = .color(.red)
        let viewBackground: ContainerBackgroundStyle? = ContainerBackgroundStyle.none
        let containerType: ContainerType = .z

        // when
        let result = ContainerBackgroundStyle.merge(containerBackgroundStyle: containerBackground, viewBackgroundStyle: viewBackground, containerType: containerType)

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

}
