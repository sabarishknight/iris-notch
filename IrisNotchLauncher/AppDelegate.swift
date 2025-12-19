//
//  AppDelegate.swift
//  IrisNotch
//
//  Created by Sabarish G on 19/12/25.
//

import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        launchMainApp()
        NSApp.terminate(nil)
    }

    private func launchMainApp() {
        let mainAppBundleID = "com.mactimenotch.irisnotch" // ⚠️ CHANGE if different

        let runningApps = NSWorkspace.shared.runningApplications
        let isMainAppRunning = runningApps.contains {
            $0.bundleIdentifier == mainAppBundleID
        }

        guard !isMainAppRunning else { return }

        if let appURL = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: mainAppBundleID
        ) {
            NSWorkspace.shared.open(appURL)
        }
    }
}
