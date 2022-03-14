//
//  MergeTests.swift
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

class MergeTests: XCTestCase {
    func testAutoDismissMergeWhenContainerIsNone() throws {
        // given
        let containerAutoDismiss: ContainerViewAutoDismiss? = ContainerViewAutoDismiss.disable
        let viewAutoDismiss: ContainerViewAutoDismiss? = ContainerViewAutoDismiss.seconds(10)

        // when
        let result = ContainerViewAutoDismiss.merge(containerAutoDismiss: containerAutoDismiss, viewAutoDismiss: viewAutoDismiss)

        // then
        XCTAssertEqual(result, ContainerViewAutoDismiss.seconds(10))
    }

    func testAutoDismissMergeWhenBothNil() throws {
        // given
        let containerAutoDismiss: ContainerViewAutoDismiss? = nil
        let viewAutoDismiss: ContainerViewAutoDismiss? = nil

        // when
        let result = ContainerViewAutoDismiss.merge(containerAutoDismiss: containerAutoDismiss, viewAutoDismiss: viewAutoDismiss)

        // then
        XCTAssertEqual(result, ContainerViewAutoDismiss.disable)
    }

    func testAutoDismissMergeWhenContainerIsNil() throws {
        // given
        let containerAutoDismiss: ContainerViewAutoDismiss? = nil
        let viewAutoDismiss: ContainerViewAutoDismiss? = .seconds(10)

        // when
        let result = ContainerViewAutoDismiss.merge(containerAutoDismiss: containerAutoDismiss, viewAutoDismiss: viewAutoDismiss)

        // then
        XCTAssertEqual(result, ContainerViewAutoDismiss.seconds(10))
    }

    func testAutoDismissMergeWhenContainerIsNilAndViewIsNone() throws {
        // given
        let containerAutoDismiss: ContainerViewAutoDismiss? = nil
        let viewAutoDismiss: ContainerViewAutoDismiss? = ContainerViewAutoDismiss.disable

        // when
        let result = ContainerViewAutoDismiss.merge(containerAutoDismiss: containerAutoDismiss, viewAutoDismiss: viewAutoDismiss)

        // then
        XCTAssertEqual(result, ContainerViewAutoDismiss.disable)
    }

    func testAutoDismissMergeWhenBothNotNil1() throws {
        // given
        let containerAutoDismiss: ContainerViewAutoDismiss? = .seconds(10)
        let viewAutoDismiss: ContainerViewAutoDismiss? = ContainerViewAutoDismiss.disable

        // when
        let result = ContainerViewAutoDismiss.merge(containerAutoDismiss: containerAutoDismiss, viewAutoDismiss: viewAutoDismiss)

        // then
        XCTAssertEqual(result, ContainerViewAutoDismiss.disable)
    }

    func testAutoDismissMergeWhenBothNotNil2() throws {
        // given
        let containerAutoDismiss: ContainerViewAutoDismiss? = .seconds(10)
        let viewAutoDismiss: ContainerViewAutoDismiss? = .seconds(20)

        // when
        let result = ContainerViewAutoDismiss.merge(containerAutoDismiss: containerAutoDismiss, viewAutoDismiss: viewAutoDismiss)

        // then
        XCTAssertEqual(result, ContainerViewAutoDismiss.seconds(20))
    }

    func testAutoDismissMergeWhenViewIsNil() throws {
        // given
        let containerAutoDismiss: ContainerViewAutoDismiss? = .seconds(10)
        let viewAutoDismiss: ContainerViewAutoDismiss? = nil

        // when
        let result = ContainerViewAutoDismiss.merge(containerAutoDismiss: containerAutoDismiss, viewAutoDismiss: viewAutoDismiss)

        // then
        XCTAssertEqual(result, ContainerViewAutoDismiss.seconds(10))
    }
}
