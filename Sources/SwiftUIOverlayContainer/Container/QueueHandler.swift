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

final class ContainerQueueHandler: ObservableObject {
    @Published
    /// the main queue for IdentifiableView, used in SwiftUI ForEach
    var mainQueue: [IdentifiableContainerView] = []

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

    /// Pass true will empty all queues after disappear
    var emptyQueueAfterDisappear: Bool

    init(container: String,
         containerConfiguration: ContainerConfigurationProtocol,
         containerManager: ContainerManager,
         emptyQueueAfterDisappear: Bool) {
        self.container = container
        self.containerConfiguration = containerConfiguration
        self.manager = containerManager
        self.emptyQueueAfterDisappear = emptyQueueAfterDisappear
    }

    /// Register the container in the container manager. Will be called when  onAppear
    func disconnect() {
        cancellable = nil
        manager.removeContainer(for: container)
        if emptyQueueAfterDisappear {
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

        // if has isPresented Binding Value
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

enum QueueType {
    case main
    case temporary
}
