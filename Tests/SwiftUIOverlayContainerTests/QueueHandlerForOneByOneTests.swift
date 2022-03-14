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

class QueueHandlerForOneByOneTests: XCTestCase {
    let manager = ContainerManager.shared
    var containerConfiguration: ContainerConfiguration!
    var handler: ContainerQueueHandler!

    override class func setUp() {
        ContainerManager.shared.publishers.removeAll()
    }

    override class func tearDown() {
        ContainerManager.shared.publishers.removeAll()
    }

    override func setUp() {
        self.containerConfiguration = ContainerConfiguration(
            displayType: .stacking, queueType: .oneByOne, delayForShowingNext: 0
        )
        self.handler = ContainerQueueHandler(
            container: "testContainer",
            containerConfiguration: containerConfiguration,
            containerManager: manager
        )
    }

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
        perform(.show(identifiableView))

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
        perform(.show(identifiableView1))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)

        // when
        perform(.show(identifiableView2))

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
        perform(.show(identifiableView))
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
        perform(.show(identifiableView1))
        perform(.show(identifiableView2))
        perform(.dismissAll(false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testShowViewAfterConnect() throws {
        // given
        handler.connect()
        let view = MessageView()

        let container = handler.container

        // when
        manager.show(view: view, in: container, using: view)
        let id = manager.show(view: view, in: container, using: view)

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

    func testDismissViewWithIsPresented() throws {
        // given
        let mock = BindingMock()
        mock.isPresented = true
        let binding = Binding<Bool>(get: { mock.isPresented }, set: { mock.isPresented = $0 })
        handler.connect()
        let view = MessageView()
        let container = handler.container

        // when
        manager.show(view: view, in: container, using: view)
        manager.show(view: view, in: container, using: view, isPresented: binding)
        manager.dismissAllView(in: [container], animated: true)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
        XCTAssertFalse(mock.isPresented)
    }
}
