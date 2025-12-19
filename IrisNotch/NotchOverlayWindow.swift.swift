//
//  NotchOverlayWindow.swift
//  IrisNotch
//
//  Created by Sabarish G on 19/12/25.
//

import AppKit
import SwiftUI

final class NotchOverlayWindow {

    static let shared = NotchOverlayWindow()

    private var panel: NSPanel?
    private var hideWorkItem: DispatchWorkItem?

    private init() {}

    // MARK: - Show Overlay
    func show(duration: TimeInterval, mode: ReminderMode) {

        hide()

        // 🔑 Use the screen that owns the menu bar
        guard
            let mainScreen = NSScreen.main,
            let screen = NSScreen.screens.first(where: { $0.frame.maxY == mainScreen.frame.maxY })
        else { return }

        let screenFrame = screen.frame

        // MARK: - Size & View per Mode
        let width: CGFloat
        let height: CGFloat
        let rootView: AnyView

        switch mode {
        case .blink:
            width = 420
            height = 150
            rootView = AnyView(BlinkGlowView())

        case .lookAway:
            width = 520
            height = 170
            rootView = AnyView(LookAwayGlowView())
        }

        // ✅ Center + tuned offset (6% right)
        let x = floor(screenFrame.midX - (width / 2) + (width * 0.06))
        let y = screenFrame.maxY - height   // stick to absolute top

        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = NSRect(x: 0, y: 0, width: width, height: height)

        // MARK: - Panel
        let panel = NSPanel(
            contentRect: NSRect(x: x, y: y, width: width, height: height),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // 🔑 Prevent window slide/snap
        panel.animationBehavior = .none

        // MARK: - Panel Configuration (fullscreen-safe)
        panel.isFloatingPanel = true
        panel.level = .screenSaver
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.contentView = hostingView

        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]

        panel.orderFrontRegardless()
        self.panel = panel

        // MARK: - Auto-hide
        let workItem = DispatchWorkItem { [weak self] in
            self?.hide()
        }

        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration,
            execute: workItem
        )
    }

    // MARK: - Hide Overlay
    func hide() {
        hideWorkItem?.cancel()
        hideWorkItem = nil

        panel?.orderOut(nil)
        panel = nil
    }
}


