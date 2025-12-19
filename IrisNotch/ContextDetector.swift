//
//  ContextDetector.swift
//  IrisNotch
//
//  Created by Sabarish G on 19/12/25.
//

import AppKit

final class ContextDetector {

    static let shared = ContextDetector()

    private init() {}

    // Known meeting / call apps
    private let meetingApps = [
        "zoom",
        "teams",
        "meet",
        "facetime",
        "slack"
    ]

    // Known video / media apps
    private let videoApps = [
        "quicktime",
        "vlc",
        "iina",
        "netflix",
        "youtube",
        "prime video"
    ]

    // MARK: - App Detection

    func frontmostAppName() -> String {
        NSWorkspace.shared.frontmostApplication?.localizedName?.lowercased() ?? ""
    }

    // MARK: - Fullscreen Detection (heuristic)
    func isFullscreenApp() -> Bool {
        // If menu bar is hidden, user is very likely in fullscreen
        return !NSApp.presentationOptions.contains(.autoHideMenuBar)
    }

    // MARK: - Meeting / Call Detection
    func isMeetingOrCall() -> Bool {
        let name = frontmostAppName()
        return meetingApps.contains { name.contains($0) }
    }

    // MARK: - Video Playback Detection
    func isVideoPlayback() -> Bool {
        let name = frontmostAppName()
        return videoApps.contains { name.contains($0) }
    }
}

