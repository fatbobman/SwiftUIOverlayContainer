//
//  QueueHandlerForMultipleUnitTests.swift
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

class QueueHandlerForMultipleUnitTests: XCTestCase {
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
            displayType: .stacking, queueType: .multiple, delayForShowingNext: 0
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
        let view1 = IdentifiableContainerView(
            id: UUID(), view: MessageView(), viewConfiguration: MessageView(), isPresented: nil
        )
        let view2 = IdentifiableContainerView(
            id: UUID(), view: MessageView(), viewConfiguration: MessageView(), isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .multiple)

        // when
        perform(.show(view1))
        perform(.show(view2))

        // then
        XCTAssertEqual(handler.mainQueue.count, 2)
        XCTAssertEqual(handler.tempQueue.count, 0)
    }

    func testDismissView() throws {
        // given
        let view1 = IdentifiableContainerView(
            id: UUID(), view: MessageView(), viewConfiguration: MessageView(), isPresented: nil
        )
        let view2 = IdentifiableContainerView(
            id: UUID(), view: MessageView(), viewConfiguration: MessageView(), isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .multiple)

        // when
        perform(.show(view1))
        perform(.show(view2))

        // dismiss view
        perform(.dismiss(view1.id, true))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
    }

    func testDismissAllView() throws {
        // given
        let view1 = IdentifiableContainerView(
            id: UUID(), view: MessageView(), viewConfiguration: MessageView(), isPresented: nil
        )
        let view2 = IdentifiableContainerView(
            id: UUID(), view: MessageView(), viewConfiguration: MessageView(), isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .multiple)

        // when
        perform(.show(view1))
        perform(.show(view2))

        // dismiss view
        perform(.dismissAll(false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testShowViewAfterConnect() throws {
        // given
        let view1 = MessageView()
        let view2 = MessageView()

        handler.connect()

        // when
        let containerName = handler.container
        manager.show(view: view1, in: containerName, using: view1)
        manager.show(view: view2, in: containerName, using: view2)

        // then
        XCTAssertEqual(manager.containerCount, 1)
        XCTAssertEqual(handler.mainQueue.count, 2)
        XCTAssertEqual(handler.tempQueue.count, 0)

        addTeardownBlock {
            self.handler.disconnect()
            XCTAssertEqual(self.manager.containerCount, 0)
        }
    }

    func testDismissViewAfterConnect() throws {
        // given
        let view1 = MessageView()
        let view2 = MessageView()

        handler.connect()
        let containerName = handler.container

        // when
        manager.show(view: view1, in: containerName, using: view1)
        let id = manager.show(view: view2, in: containerName, using: view2)
        manager.dismiss(view: try XCTUnwrap(id), in: containerName, animated: false)

        // then
        XCTAssertEqual(manager.containerCount, 1)
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 0)

        addTeardownBlock {
            self.handler.disconnect()
        }
    }

    func testDismissAllViewAfterConnect() throws {
        // given
        let view1 = MessageView()

        handler.connect()
        let containerName = handler.container

        // when
        manager.show(view: view1, in: containerName, using: view1)
        manager.show(view: view1, in: containerName, using: view1)
        manager.show(view: view1, in: containerName, using: view1)
        manager.dismissAllView(in: [containerName], animated: false)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
        XCTAssertEqual(handler.tempQueue.count, 0)

        addTeardownBlock {
            self.handler.disconnect()
        }
    }

    func testDismissViewWithIsPresentedAfterConnected() throws {
        // given
        let source = BindingMock()
        source.isPresented = true
        let binding = Binding<Bool>(get: { source.isPresented }, set: { source.isPresented = $0 })
        let view = MessageView()
        let identifiableView = IdentifiableContainerView(id: UUID(), view: view, viewConfiguration: view, isPresented: binding)
        let perform = handler.getStrategyHandler(for: .multiple)

        // when
        perform(.show(identifiableView))
        perform(.dismissAll(true))

        // then
        XCTAssertFalse(source.isPresented)
    }
}

struct ContainerConfiguration: ContainerConfigurationProtocol {
    var displayType: ContainerViewDisplayType
    var queueType: ContainerViewQueueType
    var delayForShowingNext: TimeInterval
}
