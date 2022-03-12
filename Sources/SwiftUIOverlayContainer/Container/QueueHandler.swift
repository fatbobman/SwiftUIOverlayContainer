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
        if containerConfiguration.emptyQueueAfterDisappear {
            dismissAll(animated: false)
        }
    }

    /// Remove the container from the container manager. Will be called when onDisappear
    func connect() {
        cancellable = manager.registerContainer(for: container)
            .sink { [weak self] action in
                guard let queueType = self?.containerConfiguration.queueType else { return }
                self?.handlerStrategy(for: queueType)(action)
            }
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
        var animation: Animation?
        if flag {
            animation = Animation.merge(
                containerAnimation: containerConfiguration.animation,
                viewAnimation: identifiableView.configuration.animation
            )
        }

        // remove view
        switch queue {
        case .main:
            mainQueue.remove(view: id, with: animation)
        case .temporary:
            tempQueue.remove(view: id, with: nil)
        }

        // Set it to false if the view has isPresented binding
        identifiableView.isPresented?.wrappedValue = false
    }

    /// Dismiss all views
    func dismissAll(animated flag: Bool) {
        for identifiableView in mainQueue + tempQueue {
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
            mainQueue.push(identifiableView, with: animation)
        case .temporary:
            tempQueue.push(identifiableView, with: nil)
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
            transferNewViewFromTempQueueIfNeeded()
        case .dismissAll(let animated):
            dismissAll(animated: animated)
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
    func transferNewViewFromTempQueueIfNeeded() {
        guard mainQueue.isEmpty else { return }
        guard let view = tempQueue.pop(with: nil) else { return }
        pushViewIntoQueue(view, queue: .main)
    }
}

/// Used to represent the main queue or teh temp queue
enum QueueType {
    case main
    case temporary
}
