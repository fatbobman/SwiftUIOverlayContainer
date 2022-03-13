//
//  MultipleHander.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/10
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Combine
import Foundation
import SwiftUI

/// The core logic of Container queue. Exhibits different behaviors depends on the type of container queue.
final class ContainerQueueHandler: ObservableObject {
    /// the main queue for IdentifiableView, used in SwiftUI ForEach
    @Published var mainQueue: [IdentifiableContainerView] = []

    /// a temporary queue of IdentifiableContainerView. Use in OneByOneWaitFinish mode
    var tempQueue: [IdentifiableContainerView] = []

    /// Publisher storage
    var cancellable: AnyCancellable?

    /// Current container Name
    var container: String

    /// Container Configurations
    var containerConfiguration: ContainerConfigurationProtocol

    /// Container Manager instance
    var manager: ContainerManager

    init(container: String,
         containerConfiguration: ContainerConfigurationProtocol,
         containerManager: ContainerManager) {
        self.container = container
        self.containerConfiguration = containerConfiguration
        self.manager = containerManager
    }

    /// Register the container in the container manager. Will be called when  onAppear
    func disconnect() {
        cancellable = nil
        manager.removeContainer(for: container)
        dismissAll(animated: false)
        sendMessage(type: .info, message: "container `\(container)` disconnected", debugLevel: 2)
    }

    /// Remove the container from the container manager. Will be called when onDisappear
    func connect() {
        cancellable = manager.registerContainer(for: container)
            .sink { [weak self] action in
                self?.sendMessage(type: .info, message: "`\(self?.container ?? "")` get a action from manager \(action)", debugLevel: 2)
                guard let queueType = self?.containerConfiguration.queueType else { return }
                self?.handlerStrategy(for: queueType)(action)
            }
        sendMessage(type: .info, message: "container `\(container)` connected", debugLevel: 2)
    }

    func sendMessage(type: SwiftUIOverlayContainerLogType, message: String, debugLevel: Int) {
        manager.sendMessage(type: type, message: message, debugLevel: debugLevel)
    }
}

// MARK: Basic

extension ContainerQueueHandler {
    /// Dismiss a specific  view
    func dismiss(id: UUID, animated flag: Bool) {
        // get identifiableView
        guard let (identifiableView, queue) = getIdentifiableView(id: id) else {
            return
        }

        // setup animation
        var animation = Animation.none
        if flag {
            animation = Animation.merge(
                containerAnimation: containerConfiguration.animation,
                viewAnimation: identifiableView.configuration.animation
            )
        }

        // remove view
        switch queue {
        case .main:
            remove(view: id, from: .main, animation: animation)
        case .temporary:
            remove(view: id, from: .temporary, animation: animation)
        }

        // Set it to false if the view has isPresented binding
        identifiableView.isPresented?.wrappedValue = false
    }

    /// Dismiss all views
    func dismissAll(animated flag: Bool) {
        for identifiableView in mainQueue {
            dismiss(id: identifiableView.id, animated: flag)
        }
        for identifiableView in tempQueue {
            dismiss(id: identifiableView.id, animated: flag)
        }
    }

    /// Dismiss all view that are showing
    func dismissMainQueue(animated flag: Bool) {
        for identifiableView in mainQueue {
            dismiss(id: identifiableView.id, animated: flag)
        }
    }

    /// Push view into specific queue, which queue depends on QueueType
    func pushViewIntoQueue(_ identifiableView: IdentifiableContainerView, queue: QueueType) {
        switch queue {
        case .main:
            let animation = Animation.merge(
                containerAnimation: containerConfiguration.animation,
                viewAnimation: identifiableView.configuration.animation
            )
            withAnimation(animation) {
                mainQueue.append(identifiableView)
            }
        case .temporary:
            tempQueue.append(identifiableView)
        }
    }

    func getIdentifiableView(id: UUID) -> (view: IdentifiableContainerView, queue: QueueType)? {
        if let mainView = mainQueue.filter({ $0.id == id }).first {
            return (mainView, .main)
        } else if let temporaryView = tempQueue.filter({ $0.id == id }).first {
            return (temporaryView, .temporary)
        }
        return nil
    }

    /// remove identifiable from queue
    func remove(view id: UUID, from queue: QueueType, animation: Animation) {
        switch queue {
        case .main:
            if let index = mainQueue.firstIndex(where: { $0.id == id }) {
                withAnimation(animation) {
                    // swiftlint:disable:next redundant_discardable_let
                    let _ = mainQueue.remove(at: index)
                }
            }
        case .temporary:
            if let index = tempQueue.firstIndex(where: { $0.id == id }) {
                withAnimation(animation) {
                    // swiftlint:disable:next redundant_discardable_let
                    let _ = tempQueue.remove(at: index)
                }
            }
        }
    }
}

// MARK: - Strategy

extension ContainerQueueHandler {
    /// Return a method for specific container queue type
    func handlerStrategy(for queueType: ContainerViewQueueType) -> (OverlayContainerAction) -> Void {
        switch queueType {
        case .oneByOne:
            return sinkForOneByOne
        case .oneByOneWaitFinish:
            return sinkForOneByOneWaitFinish
        case .multiple:
            return sinkForMultiple
        }
    }

    /// Multiple strategy
    ///
    /// push view in the main queue directly.
    func sinkForMultiple(action: OverlayContainerAction) {
        switch action {
        case .show(let identifiableContainerView):
            pushViewIntoQueue(identifiableContainerView, queue: .main)
        case .dismiss(let id, let animated):
            dismiss(id: id, animated: animated)
        case .dismissAll(let animated):
            dismissAll(animated: animated)
        case .dismissShowing(let animated):
            dismissMainQueue(animated: animated)
        }
    }

    /// OneByOne strategy
    ///
    /// If there is a view in the main queue when the show action is fetched, close it first
    func sinkForOneByOne(action: OverlayContainerAction) {
        switch action {
        case .show(let identifiableContainerView):
            dismissIfNeeded()
            pushViewIntoQueue(identifiableContainerView, queue: .main)
        case .dismiss(let id, let animated):
            dismiss(id: id, animated: animated)
        case .dismissAll(let animated):
            dismissAll(animated: animated)
        case .dismissShowing(let animated):
            dismissMainQueue(animated: animated)
        }
    }

    /// OneByOneWaitFinish strategy
    ///
    /// push the view in the main queue if main queue is empty , otherwise put it in the temp queue.
    /// try to get a new view from the temp queue when the view in the main queue is dismissed
    func sinkForOneByOneWaitFinish(action: OverlayContainerAction) {
        switch action {
        case .show(let identifiableContainerView):
            if mainQueue.isEmpty {
                pushViewIntoQueue(identifiableContainerView, queue: .main)
            } else {
                pushViewIntoQueue(identifiableContainerView, queue: .temporary)
            }
        case .dismiss(let id, let animated):
            dismiss(id: id, animated: animated)
            transferNewViewFromTempQueueIfNeeded(delay: containerConfiguration.delayForShowingNext)
        case .dismissAll(let animated):
            dismissAll(animated: animated)
        case .dismissShowing(let animated):
            dismissMainQueue(animated: animated)
            transferNewViewFromTempQueueIfNeeded(delay: containerConfiguration.delayForShowingNext)
        }
    }

    /// A method for oneByOne strategy.
    ///
    /// If there is a view in the main queue, dismiss it.
    func dismissIfNeeded() {
        guard let identifiableView = mainQueue.first else { return }
        dismiss(id: identifiableView.id, animated: true)
    }

    /// A method for oneByOneWaitFinish strategy
    ///
    /// If the main queue is empty, try transfer the first view from temp queue to main queue.
    func transferNewViewFromTempQueueIfNeeded(delay seconds: TimeInterval = 0.5) {
        guard mainQueue.isEmpty else { return }
        guard let view = tempQueue.first else { return }
        tempQueue.removeFirst()
        delayToRun(seconds: seconds) {
            self.pushViewIntoQueue(view, queue: .main)
        }
    }
}

/// Used to represent the main queue or teh temp queue
enum QueueType {
    case main
    case temporary
}
