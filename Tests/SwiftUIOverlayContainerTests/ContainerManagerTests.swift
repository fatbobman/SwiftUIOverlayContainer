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
    let manager = ContainerManager.share

    override func setUp() {
        manager.publishers.removeAll()
    }

    override func tearDown() {
        manager.logger = SwiftUIOverlayContainerDefaultLogger()
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

    func testRegisterContainerUsingTheSameName() throws {
        // given

        let containerName = "message"
        let expectation = expectation(description: "same name error")
        let logger = LoggerSpy(expectation: expectation)
        manager.logger = logger
        manager.debugLevel = 2

        // when
        let _ = manager.registerContainer(for: containerName)
        let _ = manager.registerContainer(for: containerName)

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(logger.type, .error)
        XCTAssertEqual(manager.containerCount, 1)
        addTeardownBlock {
            self.manager.debugLevel = 1
        }
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
        manager.debugLevel = 2
        var resultID: UUID?

        // when
        publisher
            .sink(receiveValue: { action in
                switch action {
                case .show(let identifiableView, _):
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
                case .show(let identifiableView, _):
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
        let source = BindingMock()
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

    // test dismiss view
    func testDismissViewInSpecificContainer() throws {
        // given
        let expectationDismiss = XCTestExpectation(description: "dismiss view")
        let expectationShow = XCTestExpectation(description: "show view")
        let containerName = "pop message"
        let publisher = manager.registerContainer(for: containerName)
        let messageView = MessageView()
        var cancellable: Set<AnyCancellable> = []

        var dismissID: UUID?
        var dismissAnimated = true

        publisher.sink(receiveValue: { action in
            switch action {
            case .dismiss(let viewID, let animated):
                dismissID = viewID
                dismissAnimated = animated
                expectationDismiss.fulfill()
            case .show:
                expectationShow.fulfill()
            default:
                break
            }
        })
        .store(in: &cancellable)

        // when
        let originalID = manager.show(view: messageView, in: containerName, using: messageView)

        manager.dismiss(view: try XCTUnwrap(originalID), in: containerName, animated: false)

        // then
        wait(for: [expectationShow, expectationDismiss], timeout: 1)
        XCTAssertEqual(originalID, dismissID)
        XCTAssertFalse(dismissAnimated)
    }

    // test dismiss all view exclude specific container
    func testDismissAllViewExcludeSpecificContainer() throws {
        let container1 = "container1"
        let container2 = "container2"
        let container3 = "container3"

        let expectation1 = XCTestExpectation(description: container1)
        let expectation2 = XCTestExpectation(description: container2)

        let publisher1 = manager.registerContainer(for: container1)
        let publisher2 = manager.registerContainer(for: container2)
        let publisher3 = manager.registerContainer(for: container3)

        var cancellable: Set<AnyCancellable> = []

        publisher1
            .sink(receiveValue: { action in
                switch action {
                case .dismissAll(let animated):
                    XCTAssertTrue(animated)
                    expectation1.fulfill()
                default:
                    fatalError()
                }
            })
            .store(in: &cancellable)

        publisher2
            .sink(receiveValue: { action in
                switch action {
                case .dismissAll(let animated):
                    XCTAssertTrue(animated)
                    expectation2.fulfill()
                default:
                    fatalError()
                }
            })
            .store(in: &cancellable)

        publisher3
            .sink(receiveValue: { action in
                switch action {
                case .dismissAll:
                    XCTAssert(false, "shouldn't get action")
                default:
                    break
                }
            })
            .store(in: &cancellable)

        // when
        manager.dismissAllView(notInclude: [container3], animated: true)

        // then
        wait(for: [expectation1, expectation2], timeout: 1)
    }

    func testDismissAllViewInSpecificContainers() throws {
        let container1 = "container1"
        let container2 = "container2"
        let container3 = "container3"

        let expectation1 = XCTestExpectation(description: container1)
        let expectation2 = XCTestExpectation(description: container2)

        let publisher1 = manager.registerContainer(for: container1)
        let publisher2 = manager.registerContainer(for: container2)
        let publisher3 = manager.registerContainer(for: container3)

        var cancellable: Set<AnyCancellable> = []

        publisher1
            .sink(receiveValue: { action in
                switch action {
                case .dismissAll(let animated):
                    XCTAssertFalse(animated)
                    expectation1.fulfill()
                default:
                    fatalError()
                }
            })
            .store(in: &cancellable)

        publisher2
            .sink(receiveValue: { action in
                switch action {
                case .dismissAll(let animated):
                    XCTAssertFalse(animated)
                    expectation2.fulfill()
                default:
                    fatalError()
                }
            })
            .store(in: &cancellable)

        publisher3
            .sink(receiveValue: { action in
                switch action {
                case .dismissAll:
                    XCTAssert(false, "shouldn't get action")
                default:
                    break
                }
            })
            .store(in: &cancellable)

        // when
        manager.dismissAllView(in: [container1, container2], animated: false)

        // then
        wait(for: [expectation1, expectation2], timeout: 1)
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
        if case .error = type {
            expectation.fulfill()
        }
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

class BindingMock {
    var isPresented = true
}
