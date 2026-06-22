//
//  QueueHandlerTests.swift
//  SwiftUIOverlayContainerTests
//
//  Created by Yang Xu on 2022/3/11
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

@testable import SwiftUIOverlayContainer
import SwiftUI
import XCTest

@MainActor
class QueueHandlerTests: XCTestCase {
    let manager = ContainerManager.share
    var containerConfiguration: ContainerConfiguration!
    var handler: ContainerQueueHandler!

    @MainActor override func setUp() {
        manager.publishers.removeAll()
        manager.preservedQueueStates.removeAll()
        self.containerConfiguration = ContainerConfiguration(
            displayType: .stacking, queueType: .multiple, delayForShowingNext: 0
        )
        self.handler = makeHandler()
    }

    func makeHandler(container: String = "testContainer") -> ContainerQueueHandler {
        ContainerQueueHandler(
            container: container,
            containerManager: manager,
            queueType: containerConfiguration.queueType,
            animation: containerConfiguration.animation,
            delayForShowingNext: containerConfiguration.delayForShowingNext,
            displayOrder: .ascending
        )
    }

    @MainActor
    override func tearDown() {
        self.containerConfiguration = nil
        self.handler = nil
    }

    @MainActor func testDismiss() throws {
        // given
        let view = MessageView()
        let identifiableView = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        handler.mainQueue.push(identifiableView, with: nil)

        // when
        handler.dismiss(id: identifiableView.id, animated: false)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testDismissAll() throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let identifiableView2 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        handler.mainQueue.push(identifiableView1, with: nil)
        handler.mainQueue.push(identifiableView2, with: nil)

        // when
        handler.dismissAll(animated: false)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testDisconnectClearsQueueByDefault() async throws {
        // given
        let view = MessageView()
        handler.connect()
        let viewID = try XCTUnwrap(manager.show(view: view, in: handler.container, using: view))
        try await Task.sleep(seconds: 0.01)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID)

        // when
        handler.disconnect()

        // then
        XCTAssertEqual(manager.containerCount, 0)
        XCTAssertEqual(handler.mainQueue.count, 0)
        XCTAssertEqual(handler.tempQueue.count, 0)
    }

    func testDisconnectPreservingQueueKeepsViewDismissibleAfterReconnect() async throws {
        // given
        let view = MessageView()
        handler.connect()
        let viewID = try XCTUnwrap(manager.show(view: view, in: handler.container, using: view))
        try await Task.sleep(seconds: 0.01)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID)

        // when
        handler.disconnect(preservingQueue: true)

        // then
        XCTAssertEqual(manager.containerCount, 0)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID)

        // when
        handler.connect()
        manager.dismiss(view: viewID, in: handler.container, animated: false)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testDisconnectPreservingQueueKeepsBindingTrueUntilDismissAfterReconnect() async throws {
        // given
        let view = MessageView()
        let source = BindingMock()
        source.isPresented = true
        let binding = Binding<Bool>(get: { source.isPresented }, set: { source.isPresented = $0 })
        handler.connect()
        let viewID = try XCTUnwrap(manager._show(view: view, in: handler.container, using: view, isPresented: binding))
        try await Task.sleep(seconds: 0.01)

        // when
        handler.disconnect(preservingQueue: true)

        // then
        XCTAssertTrue(source.isPresented)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID)

        // when
        handler.connect()
        manager.dismiss(view: viewID, in: handler.container, animated: false)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertFalse(source.isPresented)
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testDisconnectPreservingQueueRestoresViewIntoRecreatedHandler() async throws {
        // given
        let view = MessageView()
        handler.connect()
        let viewID = try XCTUnwrap(manager.show(view: view, in: handler.container, using: view))
        try await Task.sleep(seconds: 0.01)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID)

        // when
        handler.disconnect(preservingQueue: true)
        let restoredHandler = makeHandler()
        restoredHandler.connect()

        // then
        XCTAssertEqual(restoredHandler.mainQueue.first?.id, viewID)
        XCTAssertEqual(restoredHandler.tempQueue.count, 0)
        XCTAssertNil(manager.preservedQueueStates[handler.container])

        // when
        manager.dismiss(view: viewID, in: restoredHandler.container, animated: false)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertEqual(restoredHandler.mainQueue.count, 0)
    }

    func testDisconnectPreservingQueueKeepsBindingTrueUntilDismissAfterHandlerRecreation() async throws {
        // given
        let view = MessageView()
        let source = BindingMock()
        source.isPresented = true
        let binding = Binding<Bool>(get: { source.isPresented }, set: { source.isPresented = $0 })
        handler.connect()
        let viewID = try XCTUnwrap(manager._show(view: view, in: handler.container, using: view, isPresented: binding))
        try await Task.sleep(seconds: 0.01)

        // when
        handler.disconnect(preservingQueue: true)
        let restoredHandler = makeHandler()
        restoredHandler.connect()

        // then
        XCTAssertTrue(source.isPresented)
        XCTAssertEqual(restoredHandler.mainQueue.first?.id, viewID)

        // when
        manager.dismiss(view: viewID, in: restoredHandler.container, animated: false)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertFalse(source.isPresented)
        XCTAssertEqual(restoredHandler.mainQueue.count, 0)
    }

    func testDisconnectPreservingQueueSkipsBindingViewDismissedBeforeHandlerRecreation() async throws {
        // given
        let view = MessageView()
        let source = BindingMock()
        source.isPresented = true
        let binding = Binding<Bool>(get: { source.isPresented }, set: { source.isPresented = $0 })
        handler.connect()
        let viewID = try XCTUnwrap(manager._show(view: view, in: handler.container, using: view, isPresented: binding))
        try await Task.sleep(seconds: 0.01)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID)

        // when
        handler.disconnect(preservingQueue: true)
        source.isPresented = false
        let restoredHandler = makeHandler()
        restoredHandler.connect()

        // then
        XCTAssertEqual(restoredHandler.mainQueue.count, 0)
        XCTAssertEqual(restoredHandler.tempQueue.count, 0)
    }

    func testPushViewIntoQueue() throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let identifiableView2 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        // when
        handler.pushViewIntoQueue(identifiableView1, queue: .main)
        handler.pushViewIntoQueue(identifiableView2, queue: .temporary)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 1)
    }

    func testDismissIfNeeded() throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        // when
        handler.pushViewIntoQueue(identifiableView1, queue: .main)
        handler.dismissIfNeeded()

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
    }

    func testTransferNewViewFromTempQueueIfNeeded() throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        handler.pushViewIntoQueue(identifiableView1, queue: .temporary)

        // when
        handler.transferNewViewFromTempQueueIfNeeded(delay: 0)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 0)
        XCTAssertEqual(handler.mainQueue.first?.id, identifiableView1.id)
    }
}
