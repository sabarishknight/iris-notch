//
//  AppDelegate.swift
//  IrisNotch
//

import AppKit
import SwiftUI
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    private var statusItem: NSStatusItem!

    // Stored menu items
    private var pauseMenuItem: NSMenuItem!
    private var resumeMenuItem: NSMenuItem!
    private var launchAtLoginItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        setupMenuBar()
        updateMenuStates()

        ReminderManager.shared.start()
    }

    // MARK: - Menu Bar
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        statusItem.button?.image = NSImage(
            systemSymbolName: "eye",
            accessibilityDescription: "Iris-Notch"
        )

        let menu = NSMenu()
        menu.delegate = self

        // Manual trigger
        menu.addItem(NSMenuItem(
            title: "Show Blink Reminder",
            action: #selector(showReminder),
            keyEquivalent: "b"
        ))

        // Pause submenu
        let pauseMenu = NSMenu()
        pauseMenu.addItem(NSMenuItem(title: "Pause 15 minutes", action: #selector(pause15), keyEquivalent: ""))
        pauseMenu.addItem(NSMenuItem(title: "Pause 30 minutes", action: #selector(pause30), keyEquivalent: ""))
        pauseMenu.addItem(NSMenuItem(title: "Pause 1 hour", action: #selector(pause60), keyEquivalent: ""))
        pauseMenu.addItem(NSMenuItem(title: "Pause 3 hours", action: #selector(pause180), keyEquivalent: ""))

        pauseMenuItem = NSMenuItem(title: "Pause Reminders", action: nil, keyEquivalent: "")
        pauseMenuItem.submenu = pauseMenu
        menu.addItem(pauseMenuItem)

        resumeMenuItem = NSMenuItem(
            title: "Resume Reminders",
            action: #selector(resumeReminders),
            keyEquivalent: "r"
        )
        menu.addItem(resumeMenuItem)

        menu.addItem(.separator())

        // Launch at Login
        launchAtLoginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        menu.addItem(launchAtLoginItem)

        // Settings
        menu.addItem(NSMenuItem(
            title: "Settings…",
            action: #selector(openSettings),
            keyEquivalent: ","
        ))

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(
            title: "Quit Iris-Notch",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
    }

    // MARK: - Menu State Sync (single source of truth)
    private func updateMenuStates() {
        let paused = ReminderManager.shared.isPaused

        pauseMenuItem.isEnabled = !paused
        resumeMenuItem.isEnabled = paused

        launchAtLoginItem.state =
            (SMAppService.mainApp.status == .enabled) ? .on : .off
    }

    // MARK: - NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        updateMenuStates()
    }

    // MARK: - Pause Actions
    @objc private func pause15() {
        ReminderManager.shared.pause(for: 15 * 60)
        updateMenuStates()
    }

    @objc private func pause30() {
        ReminderManager.shared.pause(for: 30 * 60)
        updateMenuStates()
    }

    @objc private func pause60() {
        ReminderManager.shared.pause(for: 60 * 60)
        updateMenuStates()
    }

    @objc private func pause180() {
        ReminderManager.shared.pause(for: 3 * 60 * 60)
        updateMenuStates()
    }

    @objc private func resumeReminders() {
        ReminderManager.shared.resume()
        updateMenuStates()
    }

    // MARK: - Launch at Login
    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            updateMenuStates()
        } catch {
            print("Launch at login error:", error)
        }
    }

    // MARK: - Other Actions
    @objc private func showReminder() {
        NotchOverlayWindow.shared.show(duration: 2, mode: .blink)
    }

    @objc private func openSettings() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 520),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.center()
        window.title = "Iris-Notch Settings"
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SettingsView())
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
