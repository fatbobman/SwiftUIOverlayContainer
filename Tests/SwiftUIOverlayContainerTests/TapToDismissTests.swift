//
//  TapToDismissTests.swift
//  SwiftUIOverlayContainerTests
//
//  Created by Yang Xu on 2022/3/9
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

@testable import SwiftUIOverlayContainer
import XCTest

class TapToDismissTests: XCTestCase {
    func testBothNil() throws {
        // given
        let container: Bool? = nil
        let view: Bool? = nil
        let stackingType: ContainerViewDisplayType = .stacking
        let verticalType: ContainerViewDisplayType = .vertical
        let horizontalType: ContainerViewDisplayType = .horizontal

        // when
        let stackingResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: stackingType)
        let verticalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: verticalType)
        let horizontalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: horizontalType)

        // then
        XCTAssertFalse(stackingResult)
        XCTAssertFalse(verticalResult)
        XCTAssertFalse(horizontalResult)
    }

    func testBothTrue() throws {
        // given
        let container: Bool? = true
        let view: Bool? = true
        let stackingType: ContainerViewDisplayType = .stacking
        let verticalType: ContainerViewDisplayType = .vertical
        let horizontalType: ContainerViewDisplayType = .horizontal

        // when
        let stackingResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: stackingType)
        let verticalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: verticalType)
        let horizontalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: horizontalType)

        // then
        XCTAssertTrue(stackingResult)
        XCTAssertTrue(verticalResult)
        XCTAssertTrue(horizontalResult)
    }

    func testBothFalse() throws {
        // given
        let container: Bool? = false
        let view: Bool? = false
        let stackingType: ContainerViewDisplayType = .stacking
        let verticalType: ContainerViewDisplayType = .vertical
        let horizontalType: ContainerViewDisplayType = .horizontal

        // when
        let stackingResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: stackingType)
        let verticalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: verticalType)
        let horizontalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: horizontalType)

        // then
        XCTAssertFalse(stackingResult)
        XCTAssertFalse(verticalResult)
        XCTAssertFalse(horizontalResult)
    }

    func testNilAndTrue() throws {
        // given
        let container: Bool? = nil
        let view: Bool? = true
        let stackingType: ContainerViewDisplayType = .stacking
        let verticalType: ContainerViewDisplayType = .vertical
        let horizontalType: ContainerViewDisplayType = .horizontal

        // when
        let stackingResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: stackingType)
        let verticalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: verticalType)
        let horizontalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: horizontalType)

        // then
        XCTAssertTrue(stackingResult)
        XCTAssertFalse(verticalResult)
        XCTAssertFalse(horizontalResult)
    }

    func testNilAndFalse() throws {
        // given
        let container: Bool? = nil
        let view: Bool? = false
        let stackingType: ContainerViewDisplayType = .stacking
        let verticalType: ContainerViewDisplayType = .vertical
        let horizontalType: ContainerViewDisplayType = .horizontal

        // when
        let stackingResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: stackingType)
        let verticalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: verticalType)
        let horizontalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: horizontalType)

        // then
        XCTAssertFalse(stackingResult)
        XCTAssertFalse(verticalResult)
        XCTAssertFalse(horizontalResult)
    }

    func testTrueAndFalse() throws {
        // given
        let container: Bool? = true
        let view: Bool? = false
        let stackingType: ContainerViewDisplayType = .stacking
        let verticalType: ContainerViewDisplayType = .vertical
        let horizontalType: ContainerViewDisplayType = .horizontal

        // when
        let stackingResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: stackingType)
        let verticalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: verticalType)
        let horizontalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: horizontalType)

        // then
        XCTAssertFalse(stackingResult)
        XCTAssertTrue(verticalResult)
        XCTAssertTrue(horizontalResult)
    }

    func testFalseAndTrue() throws {
        // given
        let container: Bool? = false
        let view: Bool? = true
        let stackingType: ContainerViewDisplayType = .stacking
        let verticalType: ContainerViewDisplayType = .vertical
        let horizontalType: ContainerViewDisplayType = .horizontal

        // when
        let stackingResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: stackingType)
        let verticalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: verticalType)
        let horizontalResult = Bool.merge(containerTapToDismiss: container, viewTapToDismiss: view, containerType: horizontalType)

        // then
        XCTAssertTrue(stackingResult)
        XCTAssertFalse(verticalResult)
        XCTAssertFalse(horizontalResult)
    }
}
