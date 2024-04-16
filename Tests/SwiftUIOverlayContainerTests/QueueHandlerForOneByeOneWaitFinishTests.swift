//
//  QueueHandlerForOneByeOneWaitFinishTests.swift
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


class QueueHandlerForOneByeOneWaitFinishTests: XCTestCase {
    let manager = ContainerManager.share
    var containerConfiguration: ContainerConfiguration!
    var handler: ContainerQueueHandler!

    @MainActor
    override func setUp() {
        manager.publishers.removeAll()
        self.containerConfiguration = ContainerConfiguration(
            displayType: .stacking, queueType: .oneByOneWaitFinish, delayForShowingNext: 0
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

    @MainActor
    func testShowView() throws {
        // given
        let view = MessageView()
        let identifiableView = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let perform = handler.getStrategyHandler(for: .oneByOneWaitFinish)

        // when
        perform(.show(identifiableView, false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
    }
  
    @MainActor
    func testShowViewOneByOne() async throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let identifiableView2 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .oneByOneWaitFinish)

        // when
        perform(.show(identifiableView1, false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)

        // when
        perform(.show(identifiableView2, false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 1)

        // when
        perform(.dismiss(identifiableView1.id, true))
        try? await Task.sleep(seconds: 0.001)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 0)
        XCTAssertEqual(handler.mainQueue.first?.id, identifiableView2.id)
    }
  
    @MainActor
    func testDismissViewInTempQueue() throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let identifiableView2 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .oneByOneWaitFinish)

        // when
        perform(.show(identifiableView1, false))
        perform(.show(identifiableView2, false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 1)

        // when
        perform(.dismiss(identifiableView2.id, true))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 0)
        XCTAssertEqual(handler.mainQueue.first?.id, identifiableView1.id)
    }
  
    @MainActor
    func testDismissAllView() async throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let identifiableView2 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .oneByOneWaitFinish)

        // when
        perform(.show(identifiableView1, false))
        perform(.show(identifiableView2, false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 1)

        // when
        perform(.dismissAll(true))

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
        XCTAssertEqual(handler.tempQueue.count, 0)
    }
  
    @MainActor
    func testDismissTopmostView() async throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let identifiableView2 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .oneByOneWaitFinish)

        // when
        perform(.show(identifiableView1, false))
        perform(.show(identifiableView2, false))
        perform(.dismissTopmostView(false))
        try? await Task.sleep(seconds: 0.001)
        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 0)
        XCTAssertEqual(handler.mainQueue.first?.id, identifiableView2.id)
    }
  
    @MainActor
    func testDismissShowingView() async throws {
        // given
        let view = MessageView()
        let identifiableView1 = IdentifiableContainerView(
            id: UUID(), view: view, viewConfiguration: view, isPresented: nil
        )
        let view2ID = UUID()
        let identifiableView2 = IdentifiableContainerView(
            id: view2ID, view: view, viewConfiguration: view, isPresented: nil
        )

        let perform = handler.getStrategyHandler(for: .oneByOneWaitFinish)

        // when
        perform(.show(identifiableView1, false))
        perform(.show(identifiableView2, false))

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 1)

        // when
        perform(.dismissShowing(true))
        try? await Task.sleep(seconds: 0.001)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 0)
        XCTAssertEqual(try XCTUnwrap(handler.mainQueue.first?.id), view2ID)
    }

    @MainActor
    func testShowViewAfterConnect() async throws {
        // given
        let view = MessageView()
        handler.connect()
        let container = handler.container

        // when
        let viewID1 = manager.show(view: view, in: container, using: view)
        let viewID2 = manager.show(view: view, in: container, using: view)
        let viewID3 = manager.show(view: view, in: container, using: view)

        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 2)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID1)
        XCTAssertEqual(handler.tempQueue.first?.id, viewID2)
        XCTAssertEqual(handler.tempQueue.last?.id, viewID3)

        addTeardownBlock {
            self.handler.disconnect()
        }
    }

    @MainActor
    func testDismissViewAfterConnect() async throws {
        // given
        let view = MessageView()
        handler.connect()
        let container = handler.container

        // when
        let viewID1 = manager.show(view: view, in: container, using: view)
        let viewID2 = manager.show(view: view, in: container, using: view)
        let viewID3 = manager.show(view: view, in: container, using: view)
        manager.dismiss(view: try XCTUnwrap(viewID1), in: container, animated: true)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 1)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID2)
        XCTAssertEqual(handler.tempQueue.first?.id, viewID3)
    }
  
    @MainActor
    func testDismissViewTransferFormTempQueueAfterConnect() async throws {
        // given
        let view = MessageView()
        handler.connect()
        let container = handler.container

        // when
        let viewID1 = manager.show(view: view, in: container, using: view)
        let viewID2 = manager.show(view: view, in: container, using: view)
        let viewID3 = manager.show(view: view, in: container, using: view)
        manager.dismiss(view: try XCTUnwrap(viewID2), in: container, animated: true)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertEqual(handler.mainQueue.count, 1)
        XCTAssertEqual(handler.tempQueue.count, 1)
        XCTAssertEqual(handler.mainQueue.first?.id, viewID1)
        XCTAssertEqual(handler.tempQueue.first?.id, viewID3)
    }
  
    @MainActor
    func testDismissAllViewAfterConnect() throws {
        // given
        let view = MessageView()
        handler.connect()
        let container = handler.container

        // when
        manager.show(view: view, in: container, using: view)
        manager.show(view: view, in: container, using: view)
        manager.show(view: view, in: container, using: view)
        manager.dismissAllView(notInclude: [], animated: true)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
        XCTAssertEqual(handler.tempQueue.count, 0)
    }

    // temp queue is not empty
    @MainActor
    func testDismissAllViewWithIsPresentedAfterConnect() async throws {
        // given
        let view = MessageView()
        handler.connect()
        let container = handler.container
        let bindMock = BindingMock()
        bindMock.isPresented = true
        let binding = Binding<Bool>(get: { bindMock.isPresented }, set: { bindMock.isPresented = $0 })

        // when
        manager.show(view: view, in: container, using: view)
        manager.show(view: view, in: container, using: view)
        manager._show(view: view, in: container, using: view, isPresented: binding)
        manager.dismissAllView(notInclude: [], animated: true)
        try await Task.sleep(seconds: 0.01)

        // then
        XCTAssertEqual(handler.mainQueue.count, 0)
        XCTAssertEqual(handler.tempQueue.count, 0)
        XCTAssertFalse(bindMock.isPresented)
    }
  
    // test query
    @MainActor
    func testQueryViews() async throws {
      // given
      let view = MessageView()
      handler.connect()
      let container = handler.container

      // when
      manager.show(view: view, in: container, using: view)
      manager.show(view: view, in: container, using: view)
      manager.show(view: view, in: container, using: view)
      let query = IdentifiableContainerViewQuery()
      manager.queryViews(in: handler.container, queryResult: query)
      try await Task.sleep(seconds: 0.01)
      
      // then
      XCTAssertEqual(query.views.count, 3)
    }
}
