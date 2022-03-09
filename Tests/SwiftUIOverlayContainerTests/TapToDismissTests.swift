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
        XCTAssertNil(stackingResult)
        XCTAssertNil(verticalResult)
        XCTAssertNil(horizontalResult)
    }
}
