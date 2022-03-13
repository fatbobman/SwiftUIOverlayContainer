//
//  CompositeContainerView.swift
//  SwiftUIOverlayContainer
//
//  Created by Yang Xu on 2022/3/12
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import Foundation
import SwiftUI

extension OverlayContainer {
    /// composite dismiss action for specific identifiable view
    func compositeDismissAction(
        for identifiableView: IdentifiableContainerView,
        containerConfiguration: ContainerConfigurationProtocol,
        queueHandler: ContainerQueueHandler
    ) -> () -> Void {
        {
            // dismiss view
            queueHandler.dismiss(id: identifiableView.id, animated: true)
            // disappear action for view
            identifiableView.configuration.disappearAction?()
            // disappear action for container
            configuration.disappearAction?()
        }
    }

    func compositeDismissActionForAllViewIsShowing(
        containerConfiguration: ContainerConfigurationProtocol,
        queueHandler: ContainerQueueHandler
    ) -> () -> Void {
        {
            for identifiableView in queueHandler.mainQueue {
                queueHandler.dismiss(id: identifiableView.id, animated: true)
                identifiableView.configuration.disappearAction?()
            }
            // disappear action for container
            configuration.disappearAction?()
        }
    }

    @ViewBuilder
    func compositeContainerBackground(containerConfiguration: ContainerConfigurationProtocol, dismissAction: @escaping () -> Void) -> some View {
        let backgroundTransition = containerConfiguration.backgroundTransitionStyle
        let tapToDismiss = Bool.merge(containerTapToDismiss: containerConfiguration.tapToDismiss, viewTapToDismiss: nil, containerType: containerConfiguration.displayType)
        if let backgroundStyle = containerConfiguration.backgroundStyle {
            backgroundStyle
                .view()
                .if(tapToDismiss) {
                    $0.onTapGesture(perform: dismissAction)
                }
                .transition(backgroundTransition.transition)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    func compositeBackgroundFor(
        identifiableView: IdentifiableContainerView,
        containerConfiguration: ContainerConfigurationProtocol,
        dismissAction: @escaping () -> Void
    ) -> some View {
        let backgroundStyle = ContainerBackgroundStyle.merge(
            containerBackgroundStyle: containerConfiguration.backgroundStyle,
            viewBackgroundStyle: identifiableView.configuration.backgroundStyle,
            containerViewDisplayType: containerConfiguration.displayType
        )

        let backgroundTransition = identifiableView.configuration.backgroundTransitionStyle
        let tapToDismiss = Bool.merge(
            containerTapToDismiss: containerConfiguration.tapToDismiss,
            viewTapToDismiss: identifiableView.configuration.tapToDismiss,
            containerType: containerConfiguration.displayType
        )

        backgroundStyle
            .view()
            .if(tapToDismiss) { $0.onTapGesture(perform: dismissAction) }
            .transition(backgroundTransition.transition)
    }

    @ViewBuilder
    func compositeContainerView(
        for identifiableView: IdentifiableContainerView,
        containerConfiguration: ContainerConfigurationProtocol,
        queueHandler: ContainerQueueHandler
    ) -> some View {
        let shadowStyle = ContainerViewShadowStyle.merge(
            containerShadow: containerConfiguration.shadowStyle,
            viewShadow: identifiableView.configuration.shadowStyle,
            containerViewDisplayType: containerConfiguration.displayType
        )
        let dismissGesture = ContainerViewDismissGesture.merge(
            containerGesture: containerConfiguration.dismissGesture, viewGesture: identifiableView.configuration.dismissGesture
        )

        let transition = AnyTransition.merge(
            containerTransition: containerConfiguration.transition,
            viewTransition: identifiableView.configuration.transition,
            containerViewDisplayType: containerConfiguration.displayType
        )
        let dismissAction = compositeDismissAction(
            for: identifiableView, containerConfiguration: containerConfiguration, queueHandler: queueHandler
        )

        let autoDismissStyle = ContainerViewAutoDismiss.merge(
            containerAutoDismiss: containerConfiguration.autoDismiss, viewAutoDismiss: identifiableView.configuration.autoDismiss
        )

        let environmentValue = compositeContainerEnvironmentValue(
            containerName: containerName,
            containerConfiguration: containerConfiguration,
            containerFrame: containerFrame,
            dismissAction: dismissAction
        )

        let pureView = identifiableView.view
            .containerViewShadow(shadowStyle)
            .transition(transition)
            .dismissGesture(gestureType: dismissGesture, dismissAction: dismissAction)
            .autoDismiss(autoDismissStyle, dismissAction: dismissAction)
            .dismissIfIsPresentedIfFalse(identifiableView.isPresented, preform: dismissAction)
            .environment(\.overlayContainer, environmentValue)

        switch containerConfiguration.displayType {
        case .horizontal, .vertical:
            // view + gesture + shadow + transition + autoDismiss + isPresented
            pureView

        case .stacking:
            // background + backgroundDismiss + view + gesture + shadow + transition + autoDismiss + isPresented + alignment + inset
            let background = compositeBackgroundFor(
                identifiableView: identifiableView, containerConfiguration: containerConfiguration, dismissAction: dismissAction
            )

            let alignment = Alignment.merge(
                containerAlignment: containerConfiguration.alignment,
                viewAlignment: identifiableView.configuration.alignment,
                containerViewDisplayType: containerConfiguration.displayType
            )

            background
            pureView
                .padding(containerConfiguration.insets) // add insets for each view
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: alignment)
        }
    }
}

extension View {
    @ViewBuilder
    func dismissIfIsPresentedIfFalse(_ isPresented: Binding<Bool>?, preform dismissAction: @escaping () -> Void) -> some View {
        ifNotNil(isPresented?.wrappedValue) { view, isPresented in
            view.onChange(of: isPresented, perform: { _ in
                if !isPresented {
                    dismissAction()
                }
            })
        }
    }
}
