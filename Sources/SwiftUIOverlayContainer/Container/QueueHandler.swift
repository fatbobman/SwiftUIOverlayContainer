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
@MainActor
final class ContainerQueueHandler: ObservableObject {
    /// the main queue for IdentifiableView, used in SwiftUI ForEach
    @Published var mainQueue: [IdentifiableContainerView] = [] {
        didSet {
            // if the main queue is empty, get a new view from the temp queue in oneByeOneWaitFinish mode
            if case .oneByOneWaitFinish = queueType, mainQueue.isEmpty {
                transferNewViewFromTempQueueIfNeeded(delay: delayForShowingNext)
            }
            // check maximum number setting ,if temp queue is not empty, get a new view into main queue in multiple mode
            if case .multiple = queueType,
               mainQueue.count < maximumNumberOfViewsInMultiple,
               !_transferring
            {
                _transferring = true
                transferNewViewFromTempQueueIfNeeded(delay: delayForShowingNext)
            }
        }
    }

    /// Whether the view is being transferred from temp queue to main queue
    var _transferring = false

    /// The temporary queue of IdentifiableContainerView. Use in OneByOneWaitFinish mode
    var tempQueue: [IdentifiableContainerView] = []

    /// Publisher storage
    var cancellable: AnyCancellable?

    /// The name of container
    var container: String

    /// The queue type of container
    let queueType: ContainerViewQueueType

    /// The container transition animation setting
    var animation: Animation?

    /// In OneByOneWaitFinish mode,The view in temporary queue are delayed for a specific number of seconds when the currently displayed view is dismissed.
    var delayForShowingNext: TimeInterval

    /// The display order of container view
    var displayOrder: ContainerDisplayOrder

    var maximumNumberOfViewsInMultiple: UInt {
        didSet {
            // if user change the max number of view at runtime, get more views from temp queue
            if maximumNumberOfViewsInMultiple > oldValue {
                transferNewViewFromTempQueueIfNeeded(delay: delayForShowingNext)
            }
        }
    }

    let queueControlOperator: QueueControlOperator

    /// Container Manager
    var manager: ContainerManager

    init(container: String,
         containerManager: ContainerManager,
         queueType: ContainerViewQueueType,
         animation: Animation?,
         delayForShowingNext: TimeInterval,
         maximumNumberOfViewsInMultiple: UInt = UInt.max,
         displayOrder: ContainerDisplayOrder,
         queueControlOperator: QueueControlOperator = .none)
    {
        self.container = container
        self.queueType = queueType
        self.animation = animation
        self.delayForShowingNext = delayForShowingNext
        manager = containerManager
        self.maximumNumberOfViewsInMultiple = maximumNumberOfViewsInMultiple
        self.displayOrder = displayOrder
        self.queueControlOperator = queueControlOperator
    }

    /// Remove the container from the container manager. This method Will be called when container disappear
    func disconnect() {
        cancellable = nil
        manager.removeContainer(for: container)
        dismissAll(animated: false)
        sendMessage(type: .info, message: "container `\(container)` disconnected", debugLevel: 2)
    }

    /// Register the container in the container manager. This method will be called when  the container appear ( not in container view init ).
    func connect() {
        let publisher: AnyPublisher<OverlayContainerAction, Never>
        switch queueControlOperator {
        case let .debounce(seconds: seconds):
            publisher = manager.registerContainer(for: container)
                .debounce(for: .seconds(seconds), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .none:
            publisher = manager.registerContainer(for: container).eraseToAnyPublisher()
        }
        cancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                self?.sendMessage(type: .info, message: "`\(self?.container ?? "")` get a action from manager \(action)", debugLevel: 2)
                guard let queueType = self?.queueType else { return }
                self?.getStrategyHandler(for: queueType)(action)
            }
        sendMessage(type: .info, message: "container `\(container)` connected", debugLevel: 2)
    }

    /// Send message with debug level to container manager logger
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
        var animation = Animation.disable
        if flag {
            animation = Animation.merge(
                containerAnimation: self.animation,
                viewAnimation: identifiableView.configuration.animation
            )
        }

        // remove view
        switch queue {
        case .main:
            remove(view: id, from: .main, animation: animation)
        case .temporary:
            remove(view: id, from: .temporary, animation: .disable)
        }

        // Set bind value (isPresented) to false
        identifiableView.isPresented?.wrappedValue = false
    }

    /// Dismiss all views in both main queue and temporary queue
    func dismissAll(animated flag: Bool) {
        // The temporary queue must be emptied first. If the main queue is emptied first, didSet will raised.
        for identifiableView in tempQueue {
            dismiss(id: identifiableView.id, animated: false)
        }
        for identifiableView in mainQueue {
            dismiss(id: identifiableView.id, animated: flag)
        }
    }

    /// Dismiss the view being displayed
    func dismissMainQueue(animated flag: Bool) {
        for identifiableView in mainQueue {
            dismiss(id: identifiableView.id, animated: flag)
        }
    }

    /// Dismiss the topmost view ( with the largest zIndex , not the top one of main queue )
    func dismissTopmostView(animated flag: Bool) {
        let theTopViewID: UUID?
        switch displayOrder {
        case .ascending:
            theTopViewID = mainQueue.sorted(by: { $0.timeStamp > $1.timeStamp }).first?.id
        case .descending:
            theTopViewID = mainQueue.sorted(by: { $0.timeStamp < $1.timeStamp }).first?.id
        }
        if let id = theTopViewID {
            dismiss(id: id, animated: flag)
        }
    }

    /// Push view into specific queue
    func pushViewIntoQueue(_ identifiableView: IdentifiableContainerView, queue: QueueType, animated flag: Bool = true) {
        var identifiableView = identifiableView
        identifiableView.timeStamp = Date()
        switch queue {
        case .main:
            var animation: Animation = .disable
            if flag {
                animation = Animation.merge(
                    containerAnimation: self.animation,
                    viewAnimation: identifiableView.configuration.animation
                )
            }
            withAnimation(animation) {
                self.mainQueue.append(identifiableView)
            }
        case .temporary:
            tempQueue.append(identifiableView)
        }
    }

    /// Get a specific identifiable view from all queues
    /// - Parameter id: identifier of view
    /// - Returns: A tuple with identifiable view and queue source
    func getIdentifiableView(id: UUID) -> (view: IdentifiableContainerView, queue: QueueType)? {
        if let mainView = mainQueue.filter({ $0.id == id }).first {
            return (mainView, .main)
        } else if let temporaryView = tempQueue.filter({ $0.id == id }).first {
            return (temporaryView, .temporary)
        }
        return nil
    }

    /// Remove a identifiable view from specific queue
    func remove(view id: UUID, from queue: QueueType, animation: Animation) {
        switch queue {
        case .main:
            if let index = mainQueue.firstIndex(where: { $0.id == id }) {
                withAnimation(animation) {
                    // swiftlint:disable:next redundant_discardable_let
                    _ = self.mainQueue.remove(at: index)
                }
            }
        case .temporary:
            if let index = tempQueue.firstIndex(where: { $0.id == id }) {
                withAnimation(animation) {
                    // swiftlint:disable:next redundant_discardable_let
                    _ = self.tempQueue.remove(at: index)
                }
            }
        }
    }
}

// MARK: - Strategy

extension ContainerQueueHandler {
    /// Get a method  based on queue type to handler he actions received from container manager
    func getStrategyHandler(for queueType: ContainerViewQueueType) -> @MainActor (OverlayContainerAction) -> Void {
        switch queueType {
        case .oneByOne:
            return sinkForOneByOne
        case .oneByOneWaitFinish:
            return sinkForOneByOneWaitFinish
        case .multiple:
            return sinkForMultiple
        }
    }

    /// Method of handling actions in multiple mode
    ///
    /// Push all views into the main queue directly whether or not the main queue is empty
    func sinkForMultiple(action: OverlayContainerAction) {
        switch action {
        case let .show(identifiableContainerView, animated):
            if mainQueue.count < maximumNumberOfViewsInMultiple, tempQueue.isEmpty {
                pushViewIntoQueue(identifiableContainerView, queue: .main, animated: animated)
            } else {
                pushViewIntoQueue(identifiableContainerView, queue: .temporary, animated: animated)
            }
        case let .dismiss(id, animated):
            dismiss(id: id, animated: animated)
        case let .dismissAll(animated):
            dismissAll(animated: animated)
        case let .dismissShowing(animated):
            dismissMainQueue(animated: animated)
        case let .dismissTopmostView(animated):
            dismissTopmostView(animated: animated)
        case let .viewQuery(containerName, query):
            if containerName == container {
              query.views = mainQueue + tempQueue
            }
        }
    }

    /// Method of handling actions in OneByOne mode
    ///
    /// If there is a view in the main queue when the show action is fetched, dismiss it first
    func sinkForOneByOne(action: OverlayContainerAction) {
        switch action {
        case let .show(identifiableContainerView, animated):
            dismissIfNeeded()
            pushViewIntoQueue(identifiableContainerView, queue: .main, animated: animated)
        case let .dismiss(id, animated):
            dismiss(id: id, animated: animated)
        case let .dismissAll(animated):
            dismissAll(animated: animated)
        case let .dismissShowing(animated):
            dismissMainQueue(animated: animated)
        case let .dismissTopmostView(animated):
            dismissTopmostView(animated: animated)
        case let .viewQuery(containerName, query):
            if containerName == container {
              query.views = mainQueue + tempQueue
            }
        }
    }

    /// Method of handling actions in OneByOneWithFinish
    ///
    /// Push view into the main queue if main queue is empty , otherwise put it in the temporary queue.
    /// Try to get a new view from the temporary queue when the view in the main queue is dismissed
    func sinkForOneByOneWaitFinish(action: OverlayContainerAction) {
        switch action {
        case let .show(identifiableContainerView, animated):
            if mainQueue.isEmpty {
                pushViewIntoQueue(identifiableContainerView, queue: .main, animated: animated)
            } else {
                pushViewIntoQueue(identifiableContainerView, queue: .temporary, animated: false)
            }
        case let .dismiss(id, animated):
            dismiss(id: id, animated: animated)
        case let .dismissAll(animated):
            dismissAll(animated: animated)
        case let .dismissShowing(animated):
            dismissMainQueue(animated: animated)
        case let .dismissTopmostView(animated):
            dismissTopmostView(animated: animated)
        case let .viewQuery(containerName, query):
            if containerName == container {
              query.views = mainQueue + tempQueue
            }
        }
    }

    /// If there is a view in the main queue, dismiss it. only used in OneByOne mode
    func dismissIfNeeded() {
        guard let identifiableView = mainQueue.first else { return }
        dismiss(id: identifiableView.id, animated: true)
    }

    /// A method for oneByOneWaitFinish strategy and multiple strategy
    ///
    /// If the main queue is empty, try transfer the first view from temp queue to main queue.
    func transferNewViewFromTempQueueIfNeeded(delay seconds: TimeInterval) {
        guard !tempQueue.isEmpty else {
            _transferring = false
            return
        }
        Task { @MainActor in
          await delayToRun(seconds: seconds) {
            guard let view = self.tempQueue.first else { return }
            self.tempQueue.removeFirst()
            self._transferring = false
            self.pushViewIntoQueue(view, queue: .main)
          }
        }
    }
}

/// Used to represent the main queue or the temp queue
enum QueueType {
    case main
    case temporary
}
