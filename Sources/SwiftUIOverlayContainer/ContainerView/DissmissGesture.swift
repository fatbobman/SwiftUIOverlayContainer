//
//  DismissGesture.swift
//
//
//  Created by Yang Xu on 2022/3/5
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//
// swiftlint:disable cyclomatic_complexity
import Foundation
import SwiftUI

/// Gesture for dismiss Container View
///
///   Convert the gesture's type to AnyGesture<Void> when using customGesture
///
///      let gesture = LongPressGesture(minimumDuration: 1, maximumDistance: 5).eraseToAnyGestureForDismiss()
///
///   Examples
///
///     var gesture:ContainerViewDismissGesture {
///            ContainerViewDismissGesture.merge(containerGesture: containerGesture, viewGesture: viewGesture)
///         }
///
///     containerView
///          .addDismissGesture(gestureType:gesture, dismissAction: some action)
///
public enum ContainerViewDismissGesture {
    case tap
    case doubleTap
    case swipeLeft
    case swipeRight
    case swipeUp
    case swipeDown
    case longPress(Double)
    case customGesture(AnyGesture<Void>)
    case disable
}

extension ContainerViewDismissGesture {
    /// generate the dismiss gesture with execution closure
    ///
    /// The dismiss Action not only includes the cancellation action of Overlay Container view,
    /// but also the dismiss closure specified by user
    func generateGesture(with dismissAction: @escaping DismissAction) -> AnyGesture<Void>? {
        // only support longPress in tvOS
        #if os(tvOS)
        switch self {
        case .longPress(let seconds):
            return LongPressGesture(minimumDuration: seconds).onEnded { _ in dismissAction() }.eraseToAnyGestureForDismiss()
        default:
            return nil
        }
        #else
        switch self {
        case .tap:
            return TapGesture(count: 1).onEnded { _ in dismissAction() }.eraseToAnyGestureForDismiss()
        case .doubleTap:
            return TapGesture(count: 2).onEnded { _ in dismissAction() }.eraseToAnyGestureForDismiss()
        case .longPress(let seconds):
            return LongPressGesture(minimumDuration: seconds).onEnded { _ in dismissAction() }.eraseToAnyGestureForDismiss()
        case .customGesture(let gesture):
            return gesture.onEnded { _ in dismissAction() }.eraseToAnyGestureForDismiss()
        case .disable:
            return nil
        case .swipeUp, .swipeDown, .swipeLeft, .swipeRight:
            return SwipeGesture(minimumDistance: 10, coordinateSpace: .global)
                .onEnded { direction in
                    switch (direction, self) {
                    case (.left, .swipeLeft):
                        dismissAction()
                    case (.right, .swipeRight):
                        dismissAction()
                    case (.up, .swipeUp):
                        dismissAction()
                    case (.down, .swipeDown):
                        dismissAction()
                    default:
                        break
                    }
                }
                .eraseToAnyGestureForDismiss()
        }
        #endif
    }

    /// Provides the correct gesture of dismiss based on the container configuration and the container view configuration.
    ///
    /// Container view configuration's dismiss gesture has higher priority than the one of container configuration
    ///
    ///     container             view                    result
    ///
    ///         nil               nil                     disable
    ///         disable           disable                 disable
    ///         tap               nil                     tap
    ///         tap               disable                 disable
    ///         tap               swipeLeft               swipeLeft
    ///         nil               tap                     tap
    ///         nil               disable                 disable
    ///
    /// - Returns: ContainerViewDismissGesture
    static func merge(containerGesture: Self?, viewGesture: Self?) -> Self {
        guard let containerGesture = containerGesture else { return viewGesture ?? Self.disable }
        return viewGesture ?? containerGesture
    }
}

public extension Gesture {
    /// Erase SwiftUI Gesture to AnyGesture , and convert value to Void.
    ///
    /// Convert the gesture's type to AnyGesture<Void> when using customGesture
    ///
    ///      let gesture = LongPressGesture(minimumDuration: 1, maximumDistance: 5).eraseToAnyGestureForDismiss()
    ///
    func eraseToAnyGestureForDismiss() -> AnyGesture<Void> {
        AnyGesture(map { _ in () })
    }
}

#if !os(tvOS)
/// Swipe Gesture
///
/// Read my blog [post](https://fatbobman.com/posts/swiftuiGesture/) to learn how to customize gesture in SwiftUI.
struct SwipeGesture: Gesture {
    enum Direction: String {
        case left, right, up, down
    }

    typealias Value = Direction

    private let minimumDistance: CGFloat
    private let coordinateSpace: CoordinateSpace

    init(minimumDistance: CGFloat = 10, coordinateSpace: CoordinateSpace = .local) {
        self.minimumDistance = minimumDistance
        self.coordinateSpace = coordinateSpace
    }

    var body: AnyGesture<Value> {
        AnyGesture(
            DragGesture(minimumDistance: minimumDistance, coordinateSpace: coordinateSpace)
                .map { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height

                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < 0 { return .left } else { return .right }
                    } else {
                        if verticalAmount < 0 { return .up } else { return .down }
                    }
                }
        )
    }
}
#endif

extension View {
    /// Add dismiss gesture to container view
    ///
    ///   Examples
    ///
    ///     var gesture:ContainerViewDismissGesture {
    ///            ContainerViewDismissGesture.merge(containerGesture: containerGesture, viewGesture: viewGesture)
    ///         }
    ///
    ///     containerView
    ///          .dismissGesture(gestureType:gesture, dismissAction: some action)
    ///
    @ViewBuilder
    func dismissGesture(gestureType: ContainerViewDismissGesture, dismissAction: @escaping () -> Void) -> some View {
        if let gesture = gestureType.generateGesture(with: dismissAction) {
            self.gesture(gesture)
        } else { self }
    }
}
