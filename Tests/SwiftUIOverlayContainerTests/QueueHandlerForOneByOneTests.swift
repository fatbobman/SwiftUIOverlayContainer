//
//  QueueHandlerForOneByOneTests.swift
//  SwiftUIOverlayContainerTests
//
//  Created by Yang Xu on 2022/3/11
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import SwiftUI
@testable import SwiftUIOverlayContainer
import XCTest

@MainActor
class QueueHandlerForOneByOneTests: XCTestCase {
    let manager = ContainerManager.share
    var containerConfiguration: ContainerConfiguration!
    var handler: ContainerQueueHandler!

    @MainActor
    override func setUp() {
        manager.publishers.removeAll()
        self.containerConfiguration = ContainerConfiguration(
            displayType: .stacking, queueType: .oneByOne, delayForShowingNext: 0
        )
        self.handler = ContainerQueueHandler(
            container: "testContainer",
            containerManager: manager,
            queueType: containerConfiguration.queueType,
            animation: containerConfiguration.animation,
            delayForShowingNext: containerConfiguration.delayForShowingNext
        )
    }

    @MainActor
    override func tearDown() {
        self.containerConfiguration = nil
        self.handler = nil
    }

    func testShowView() throws {
        // given
        let view = MessageView()
        let identifiableView = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let perform = handler.getStrategyHandler(for: .oneByOne)

        // when
        perform(.show(identifiableView, true))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
    }

    func testShowViewOneByOne() throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let identifiableView2 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .oneByOne)

        // when
        perform(.show(identifiableView1, true))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)

        // when
        perform(.show(identifiableView2, true))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 0)
        XCTAssertEqual(handler.mainQueue.first?.id, identifiableView2.id)
    }

    func testDismissView() throws {
        // given
        let view = MessageView()
        let identifiableView = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let perform = handler.getStrategyHandler(for: .oneByOne)

        // when
        perform(.show(identifiableView, true))
        perform(.dismiss(identifiableView.id, true))

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testDismissAllView() throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let identifiableView2 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .oneByOne)

        // when
        perform(.show(identifiableView1, true))
        perform(.show(identifiableView2, true))
        perform(.dismissAll(false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testShowViewAfterConnect() async throws {
        // given
        handler.connect()
        let view = MessageView()

        let container = handler.container

        // when
        manager.show(view: view, in: container, using: view)
        let id = manager.show(view: view, in: container, using: view)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.mainQueue.first?.id, id)
    }

    func testDismissViewAfterConnect() throws {
        // given
        handler.connect()
        let view = MessageView()

        let container = handler.container

        // when
        manager.show(view: view, in: container, using: view)
        let id = manager.show(view: view, in: container, using: view)
        manager.dismiss(view: try XCTUnwrap(id), in: container, animated: true)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testDismissAllViewAfterConnect() throws {
        // given
        handler.connect()
        let view = MessageView()

        let container = handler.container

        // when
        manager.show(view: view, in: container, using: view)
        manager.show(view: view, in: container, using: view)
        manager.dismissAllView(in: [container], animated: true)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testDismissViewWithIsPresented() async throws {
        // given
        let mock = BindingMock()
        mock.isPresented = true
        let binding = Binding<Bool>(get: { mock.isPresented }, set: { mock.isPresented = $0 })
        handler.connect()
        let view = MessageView()
        let container = handler.container

        // when
        manager.show(view: view, in: container, using: view)
        manager._show(view: view, in: container, using: view, isPresented: binding)
        manager.dismissAllView(in: [container], animated: true)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
        XCTAssertFalse(mock.isPresented)
    }
}
