//
//  TransitionMergeTests.swift
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

class TransitionMergeTests: XCTestCase {
    func testTransitionMergeWhenContainerIsNilAndContainerViewDisplayTypeIsX() throws {
        // given
        let containerTransition: AnyTransition? = nil
        let viewTransition: AnyTransition? = nil
        let containerViewDisplayType: ContainerViewDisplayType = .horizontal

        // when
        let result = AnyTransition.merge(
            containerTransition: containerTransition,
            viewTransition: viewTransition,
            containerViewDisplayType: containerViewDisplayType
        )

        // then
        dump(result)

        /*
         AnyTransition erase all detail , I have on ideal how to test it now.
         */
    }
}
