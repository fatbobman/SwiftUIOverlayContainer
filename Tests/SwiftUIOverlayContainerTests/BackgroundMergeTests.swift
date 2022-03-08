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
    func testBackgroundMergeWhenBothNilAndContainerViewDisplayTypeIsX() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = nil
        let containerViewDisplayType: ContainerViewDisplayType = .horizontal

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenBothNilAndContainerViewDisplayTypeIsZ() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = nil
        let containerViewDisplayType: ContainerViewDisplayType = .stacking

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenContainerIsNilAndContainerViewDisplayTypeIsX() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerViewDisplayType: ContainerViewDisplayType = .horizontal

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenContainerIsNilAndContainerViewDisplayTypeIsZ() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerViewDisplayType: ContainerViewDisplayType = .stacking

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .blur:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenContainerIsNilAndContainerViewDisplayTypeIsY() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = nil
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerViewDisplayType: ContainerViewDisplayType = .vertical

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenBothNotNilAndContainerViewDisplayTypeIsX() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = .color(.red)
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerViewDisplayType: ContainerViewDisplayType = .horizontal

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .color:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenBothNotNilAndContainerViewDisplayTypeIsY() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = .color(.red)
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerViewDisplayType: ContainerViewDisplayType = .vertical

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .color:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenBothNotNilAndContainerViewDisplayTypeIsZ() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = .color(.red)
        let viewBackground: ContainerBackgroundStyle? = .blur(.regular)
        let containerViewDisplayType: ContainerViewDisplayType = .stacking

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .blur:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }

    func testBackgroundMergeWhenViewIsNoneAndContainerViewDisplayTypeIsZ() throws {
        // given
        let containerBackground: ContainerBackgroundStyle? = .color(.red)
        let viewBackground: ContainerBackgroundStyle? = ContainerBackgroundStyle.none
        let containerViewDisplayType: ContainerViewDisplayType = .stacking

        // when
        let result = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerBackground,
            viewBackgroundStyle: viewBackground,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        switch result {
        case .none:
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }
}
