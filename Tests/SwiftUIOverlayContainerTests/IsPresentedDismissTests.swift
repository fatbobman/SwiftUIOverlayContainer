//
//  IsPresentedDismissTests.swift
//  SwiftUIOverlayContainerTests
//
//  Created by Yang Xu on 2026/6/22
//  Copyright © 2026 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Testing
@testable import SwiftUIOverlayContainer

@Test func dismissesWhenChangedValueAndCurrentValueAreFalse() {
    #expect(
        shouldDismissViewWhenIsPresentedChanges(to: false, currentValue: false)
    )
}

@Test func doesNotDismissWhenChangedValueIsTrue() {
    #expect(
        !shouldDismissViewWhenIsPresentedChanges(to: true, currentValue: true)
    )
}

@Test func doesNotDismissWhenCurrentValueHasReturnedToTrue() {
    #expect(
        !shouldDismissViewWhenIsPresentedChanges(to: false, currentValue: true)
    )
}
