//
//  File.swift
//  
//
//  Created by Yang Xu on 2023/3/15.
//

import Foundation
import XCTest
@testable import SwiftUIOverlayContainer

@MainActor
class QueueControlOpretorTests: XCTestCase {
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
      delayForShowingNext: containerConfiguration.delayForShowingNext,
      displayOrder: .ascending,
      queueControlOperator: .last(seconds: 1)
    )
  }
  
  @MainActor
  override func tearDown() {
    self.containerConfiguration = nil
    self.handler = nil
  }
  
  func testControlOperatorLast() async throws {
    // given
    let configuration = ContainerConfiguration(
      displayType: .stacking, queueType: .multiple, delayForShowingNext: 0,queueControlOperator: .last(seconds: 0.3)
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
    XCTAssertEqual(logger.messages.count, 1)
    XCTAssertTrue(logger.messages.first!.contains("\(uuid2.uuidString)"))
  }
  
  func testControlOperatorFirst() async throws {
    // given
    let configuration = ContainerConfiguration(
      displayType: .stacking, queueType: .multiple, delayForShowingNext: 0,queueControlOperator: .first(seconds: 0.3)
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
    XCTAssertEqual(logger.messages.count, 1)
    XCTAssertTrue(logger.messages.first!.contains("\(uuid1.uuidString)"))
  }
  
  func testControlOperatorNone() async throws {
    // given
    let configuration = ContainerConfiguration(
      displayType: .stacking, queueType: .multiple, delayForShowingNext: 0,queueControlOperator: .none
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

    func log(type: SwiftUIOverlayContainerLogType, message: String) {
      if message.contains("get a action from manager") {
        messages.append(message)
      }
    }
}
