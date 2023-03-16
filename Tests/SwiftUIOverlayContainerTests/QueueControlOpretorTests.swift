//
//  File.swift
//
//
//  Created by Yang Xu on 2023/3/15.
//

import Foundation
@testable import SwiftUIOverlayContainer
import XCTest

@MainActor
class QueueControlOpretorTests: XCTestCase {
    let manager = ContainerManager.share

    @MainActor
    override func setUp() {
        manager.publishers.removeAll()
    }

    @MainActor
    override func tearDown() {}

    func testControlOperatorDebounce() async throws {
        // given
        let configuration = ContainerConfiguration(
            displayType: .stacking, queueType: .multiple, delayForShowingNext: 0, queueControlOperator: .debounce(seconds: 0.1)
        )

        let handler = ContainerQueueHandler(
            container: "testContainer",
            containerManager: manager,
            queueType: configuration.queueType,
            animation: configuration.animation,
            delayForShowingNext: configuration.delayForShowingNext,
            displayOrder: .ascending,
            queueControlOperator: configuration.queueControlOperator
        )

        let logger = ActionSpy()
        manager.logger = logger
        manager.debugLevel = 2

        handler.connect()

        let view = MessageView()
        let uuid1 = UUID()
        let uuid2 = UUID()

        manager._show(view: view, with: uuid1, in: "testContainer", using: configuration)
        manager._show(view: view, with: uuid2, in: "testContainer", using: configuration)

        try? await Task.sleep(seconds: 0.12)
        XCTAssertEqual(logger.messages.count, 1)
        XCTAssertTrue(logger.messages.first!.contains("\(uuid2.uuidString)"))
    }

    func testControlOperatorNone() async throws {
        // given
        let configuration = ContainerConfiguration(
            displayType: .stacking, queueType: .multiple, delayForShowingNext: 0, queueControlOperator: .none
        )

        let handler = ContainerQueueHandler(
            container: "testContainer",
            containerManager: manager,
            queueType: configuration.queueType,
            animation: configuration.animation,
            delayForShowingNext: configuration.delayForShowingNext,
            displayOrder: .ascending,
            queueControlOperator: configuration.queueControlOperator
        )

        let logger = ActionSpy()
        manager.logger = logger
        manager.debugLevel = 2

        handler.connect()

        let view = MessageView()
        let uuid1 = UUID()
        let uuid2 = UUID()

        manager._show(view: view, with: uuid1, in: "testContainer", using: configuration)
        manager._show(view: view, with: uuid2, in: "testContainer", using: configuration)

        try? await Task.sleep(seconds: 0.2)
        XCTAssertEqual(logger.messages.count, 2)
    }
}

class ActionSpy: SwiftUIOverlayContainerLoggerProtocol {
    var messages: [String] = []

    func log(type _: SwiftUIOverlayContainerLogType, message: String) {
        if message.contains("get a action from manager") {
            messages.append(message)
        }
    }
}
