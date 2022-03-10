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

    override func tearDown() {
        ContainerManager.logger = SwiftUIOverlayContainerDefaultLogger()
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
        let expectation = XCTestExpectation(description: "get view from container 1")
        var cancellable: Set<AnyCancellable> = []
        ContainerManager.debugLevel = 2
        var resultID: UUID?

        // when
        publisher
            .sink(receiveValue: { action in
                switch action {
                case .show(let identifiableView):
                    resultID = identifiableView.id
                    expectation.fulfill()
                default:
                    break
                }
            })
            .store(in: &cancellable)

        let viewID = manager.show(view: messageView, in: containerName, using: messageView)

        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(resultID, viewID)
    }

    func testSendViewWithGetPublisher() throws {
        // given
        let containerName = "message"
        let messageView = MessageView()
        let _ = manager.registerContainer(for: containerName)
        let expectation = XCTestExpectation(description: "get view from container 2")
        var cancellable: Set<AnyCancellable> = []
        var resultID: UUID?

        // when
        let publisher = manager.getPublisher(for: containerName)
        publisher?
            .sink(receiveValue: { action in
                switch action {
                case .show(let identifiableView):
                    resultID = identifiableView.id
                    expectation.fulfill()
                default:
                    break
                }
            })
            .store(in: &cancellable)

        let viewID = manager.show(view: messageView, in: containerName, using: messageView)

        // then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewID, resultID)
    }

    func testIsPresent() throws {
        // given
        let source = BindingSource()
        let view = MessageView()
        let binding = Binding<Bool>(get: { source.isPresented }, set: { source.isPresented = $0 })
        let viewID = UUID()
        let identifiableView = IdentifiableContainerView(id: viewID, view: view, viewConfiguration: view, isPresented: binding)

        // when
        source.isPresented = false
        let isPresented = try XCTUnwrap(identifiableView.isPresented)

        // then
        XCTAssertFalse(isPresented.wrappedValue)
    }

    // test dismiss
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

extension MessageView: ContainerViewConfigurationProtocol {
    var transition: AnyTransition? { nil }
    var autoDismiss: ContainerViewAutoDismiss? { nil }
    var dismissGesture: ContainerViewDismissGesture? { nil }
    var animation: Animation? { nil }
    var disappearAction: (() -> Void)? {{}}
    var appearAction: (() -> Void)? {{}}
    var alignment: Alignment? { nil }
    var tapToDismiss: Bool? { nil }
    var backgroundStyle: ContainerBackgroundStyle? { nil }
    var shadowStyle: ContainerViewShadowStyle? { nil }
}

class BindingSource {
    var isPresented = true
}
