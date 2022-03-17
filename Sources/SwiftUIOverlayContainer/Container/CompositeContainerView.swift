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
    /// Composite dismiss action for specific identifiable view
    func compositeDismissAction(
        for identifiableView: IdentifiableContainerView,
        containerConfiguration: ContainerConfigurationProtocol,
        queueHandler: ContainerQueueHandler
    ) -> () -> Void {
        {
            // dismiss view
            queueHandler.dismiss(id: identifiableView.id, animated: true)
        }
    }

    /// Composite dismiss action for tapped background to dismiss all view in vertical type or horizontal type
    func compositeDismissActionForAllViewIsShowing(
        containerConfiguration: ContainerConfigurationProtocol,
        queueHandler: ContainerQueueHandler
    ) -> () -> Void {
        {
            for identifiableView in queueHandler.mainQueue {
                queueHandler.dismiss(id: identifiableView.id, animated: true)
            }
        }
    }

    /// Composite background view for vertical mode or horizontal mode, used in OverlayContainer
    ///
    /// Including transition of background and dismiss action ( tapToDismiss is true )
    @ViewBuilder
    func compositeContainerBackground(
        containerConfiguration: ContainerConfigurationProtocol,
        queueHandler: ContainerQueueHandler
    ) -> some View {
        let backgroundTransition = containerConfiguration.backgroundTransitionStyle
        #if !os(tvOS)
        let tapToDismiss = Bool.merge(
            containerTapToDismiss: containerConfiguration.tapToDismiss,
            viewTapToDismiss: nil,
            containerType: containerConfiguration.displayType
        )
        let dismissAction = compositeDismissActionForAllViewIsShowing(
            containerConfiguration: containerConfiguration, queueHandler: queueHandler
        )
        #endif
        if let backgroundStyle = containerConfiguration.backgroundStyle {
            backgroundStyle
                .view()
            #if !os(tvOS)
                .if(tapToDismiss) {
                    $0.onTapGesture(perform: dismissAction)
                }
            #endif
                .transition(backgroundTransition.transition)
        } else {
            Color.clear
        }
    }

    /// Composite background view of identifiable view in stacking mode, used in compositeContainerView method
    ///
    /// Including transition of background and dismiss action ( tapToDismiss is true )
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
        #if !os(tvOS)
        let tapToDismiss = Bool.merge(
            containerTapToDismiss: containerConfiguration.tapToDismiss,
            viewTapToDismiss: identifiableView.configuration.tapToDismiss,
            containerType: containerConfiguration.displayType
        )
        #endif
        backgroundStyle
            .view()
        #if !os(tvOS)
            .if(tapToDismiss) { $0.onTapGesture(perform: dismissAction) }
        #endif
            .transition(backgroundTransition.transition)
    }

    /// Composite the view displayed in the container.
    ///
    /// Views have different modifiers and behaviors depending on the display type of container
    ///
    /// composite view, gesture, shadow, transition, autoDismiss, isPresented ( handle bind value) for the container of horizontal type or vertical type
    ///
    /// composite background, backgroundDismiss, view, gesture, shadow, transition, autoDismiss, isPresented, alignment, inset for the stacking container
    ///
    @ViewBuilder
    func compositeContainerView(
        for identifiableView: IdentifiableContainerView,
        containerConfiguration: ContainerConfigurationProtocol,
        queueHandler: ContainerQueueHandler,
        containerName: String,
        containerFrame: CGRect
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

        let compositingView = identifiableView.view
            .containerViewShadow(shadowStyle)
            .transition(transition)
            .dismissGesture(gestureType: dismissGesture, dismissAction: dismissAction)
            .autoDismiss(autoDismissStyle, dismissAction: dismissAction)
            .dismissViewWhenIsPresentedIsFalse(identifiableView.isPresented, preform: dismissAction)
            .environment(\.overlayContainer, environmentValue)

        switch containerConfiguration.displayType {
        case .horizontal, .vertical:
            // view + gesture + shadow + transition + autoDismiss + isPresented
            compositingView

        case .stacking:
            // background + backgroundDismiss + view + gesture + shadow + transition + autoDismiss + isPresented + alignment + inset
            let backgroundOfIdentifiableView = compositeBackgroundFor(
                identifiableView: identifiableView, containerConfiguration: containerConfiguration, dismissAction: dismissAction
            )

            let alignment = Alignment.merge(
                containerAlignment: containerConfiguration.alignment,
                viewAlignment: identifiableView.configuration.alignment,
                containerViewDisplayType: containerConfiguration.displayType
            )
            // the current context of view is ZStack (GenericStack)
            backgroundOfIdentifiableView
                .zIndex(1.0)
            compositingView
                .padding(containerConfiguration.insets) // add insets for each view
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: alignment)
                .zIndex(2.0)
        }
    }
}

extension View {
    /// preform action when the optional bind value set to false
    @ViewBuilder
    func dismissViewWhenIsPresentedIsFalse(_ isPresented: Binding<Bool>?, preform dismissAction: @escaping () -> Void) -> some View {
        ifNotNil(isPresented?.wrappedValue) { view, isPresented in
            view.onChange(of: isPresented, perform: { _ in
                if !isPresented {
                    dismissAction()
                }
            })
        }
    }
}
