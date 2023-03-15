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
      queueControlOperator: .lastest(seconds: 1)
    )
  }
  
  @MainActor
  override func tearDown() {
    self.containerConfiguration = nil
    self.handler = nil
  }
  
  func testShowView() async throws {
    // given
    let view = MessageView()
    let uuid1 = UUID()
    let uuid2 = UUID()
    let identifiableView1 = IdentifiableContainerView(
      id: uuid1, view: view, viewConfiguration: view, isPresented: nil
    )
    let identifiableView2 = IdentifiableContainerView(
      id: uuid2, view: view, viewConfiguration: view, isPresented: nil
    )
    handler.connect()
    
    manager._show(containerView: view, in: "testContainer")
    manager._show(containerView: view, in: "testContainer")
    // then

//    try? await Task.sleep(seconds: 2)
  }
}
