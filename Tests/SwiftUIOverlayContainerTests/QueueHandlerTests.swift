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
import XCTest

class QueueHandlerTests: XCTestCase {
    let manager = ContainerManager.share
    var containerConfiguration: ContainerConfiguration!
    var handler: ContainerQueueHandler!

    @MainActor override func setUp() {
        manager.publishers.removeAll()
        self.containerConfiguration = ContainerConfiguration(
            displayType: .stacking, queueType: .multiple, delayForShowingNext: 0
        )
        self.handler = ContainerQueueHandler(
            container: "testContainer",
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

    @MainActor
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

    @MainActor
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

    @MainActor
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

    @MainActor
    func testTransferNewViewFromTempQueueIfNeeded() async throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        handler.pushViewIntoQueue(identifiableView1, queue: .temporary)

        // when
        handler.transferNewViewFromTempQueueIfNeeded(delay: 0)
        try? await Task.sleep(seconds: 0.001)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 0)
        XCTAssertEqual(handler.mainQueue.first?.id, identifiableView1.id)
    }
}
