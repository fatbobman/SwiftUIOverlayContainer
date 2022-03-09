//
//  ContainerManagerTests.swift
//  SwiftUIOverlayContainerTests
//
//  Created by Yang Xu on 2022/3/9
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Combine
import SwiftUI
@testable import SwiftUIOverlayContainer
import XCTest

// swiftlint:disable redundant_discardable_let

class ContainerManagerTests: XCTestCase {
    let manager = ContainerManager.shared

    override func setUp() {
        manager.publishers.removeAll()
    }

    func testRegisterContainer() throws {
        // given
        let containerName = "message"

        // when
        let _ = manager.registerContainer(for: containerName)

        // then
        XCTAssertEqual(manager.containerCount, 1)
    }

    func testMultipleRegisterContainer() throws {
        // given
        let containerName1 = "message1"
        let containerName2 = "message2"

        // when
        let _ = manager.registerContainer(for: containerName1)
        let _ = manager.registerContainer(for: containerName2)

        // then
        XCTAssertEqual(manager.containerCount, 2)
    }

    func testRegisterContainerUsingSameName() throws {
        // given

        let containerName = "message"
        let expectation = expectation(description: "same name error")
        let logger = LoggerSpy(expectation: expectation)
        ContainerManager.logger = logger

        // when
        let _ = manager.registerContainer(for: containerName)
        let _ = manager.registerContainer(for: containerName)

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(logger.type, .error)
        XCTAssertEqual(manager.containerCount, 1)
    }

    func testRemoveContainer() throws {
        // given
        let containerName = "message"

        // when
        let _ = manager.registerContainer(for: containerName)
        manager.removeContainer(for: containerName)

        // then
        XCTAssertEqual(manager.containerCount, 0)
    }

    func testSendView() throws {
        // given
        let containerName = "message"
        let messageView = MessageView()
        let publisher = manager.registerContainer(for: containerName)
        let expectation = XCTestExpectation(description: "get view from container")
        var cancellable: Set<AnyCancellable> = []
        var resultView: IdentifiableContainerView?

        // when
        publisher
            .sink(receiveValue: { containerView in
                resultView = containerView
                expectation.fulfill()
            })
            .store(in: &cancellable)

        manager.show(view: messageView, in: containerName, using: messageView)

        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertNotNil(resultView)
    }

    func testSendViewWithGetPublisher() throws {
        // given
        let containerName = "message"
        let messageView = MessageView()
        let _ = manager.registerContainer(for: containerName)
        let expectation = XCTestExpectation(description: "get view from container")
        var cancellable: Set<AnyCancellable> = []
        var resultView: IdentifiableContainerView?

        // when
        let publisher = manager.getPublisher(for: containerName)
        publisher?
            .sink(receiveValue: { containerView in
                resultView = containerView
                expectation.fulfill()
            })
            .store(in: &cancellable)

        manager.show(view: messageView, in: containerName, using: messageView)

        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertNotNil(resultView)
    }

    func testIsPresent() throws {
        // given
        let source = BindingSource()
        let view = MessageView()
        let binding = Binding<Bool>(get: { source.isPresented }, set: { source.isPresented = $0 })
        let identifiableView = IdentifiableContainerView(view: view, viewConfiguration: view, isPresented: binding)

        // when
        source.isPresented = false
        let isPresented = try XCTUnwrap(identifiableView.isPresented)

        // then
        XCTAssertFalse(isPresented.wrappedValue)
    }
}

class LoggerSpy: SwiftUIOverlayContainerLoggerProtocol {
    var type: SwiftUIOverlayContainerLogType?
    var message: String?
    let expectation: XCTestExpectation
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func log(type: SwiftUIOverlayContainerLogType, message: String) {
        self.type = type
        self.message = message
        print("[\(type.rawValue)] \(message)")
        expectation.fulfill()
    }
}

struct MessageView: View {
    var body: some View {
        Text("Message")
    }
}

extension MessageView: ContainerViewConfiguration {}

class BindingSource {
    var isPresented = true
}
