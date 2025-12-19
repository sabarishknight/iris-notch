//
//  ReminderManager.swift
//  IrisNotch
//
//  Created by Sabarish G on 19/12/25.
//

import Foundation
import Combine

final class ReminderManager: ObservableObject {

    // MARK: - Singleton
    static let shared = ReminderManager()

    // Prevent saving while loading defaults
    private var isLoading = true

    // MARK: - User Settings
    @Published var blinkEnabled: Bool = true {
        didSet { persist(blinkEnabled, Keys.blinkEnabled) }
    }

    @Published var lookAwayEnabled: Bool = true {
        didSet { persist(lookAwayEnabled, Keys.lookAwayEnabled) }
    }

    // MARK: - Context Rules
    @Published var allowInFullscreen: Bool = true {
        didSet { persist(allowInFullscreen, Keys.allowInFullscreen) }
    }

    @Published var allowInVideoFullscreen: Bool = false {
        didSet { persist(allowInVideoFullscreen, Keys.allowInVideoFullscreen) }
    }

    @Published var allowDuringMeetings: Bool = false {
        didSet { persist(allowDuringMeetings, Keys.allowDuringMeetings) }
    }

    @Published var allowDuringDND: Bool = false {
        didSet { persist(allowDuringDND, Keys.allowDuringDND) }
    }

    // MARK: - Timing Settings
    @Published var blinkInterval: TimeInterval = 30 {
        didSet { persist(blinkInterval, Keys.blinkInterval) }
    }

    @Published var blinkDuration: TimeInterval = 2 {
        didSet { persist(blinkDuration, Keys.blinkDuration) }
    }

    @Published var lookInterval: TimeInterval = 20 * 60 {
        didSet { persist(lookInterval, Keys.lookInterval) }
    }

    @Published var lookDuration: TimeInterval = 20 {
        didSet { persist(lookDuration, Keys.lookDuration) }
    }

    // MARK: - Pause State
    @Published var isPaused: Bool = false
    @Published var pauseRemaining: TimeInterval = 0

    private var pauseWorkItem: DispatchWorkItem?

    // MARK: - Live Countdown
    @Published var blinkRemaining: TimeInterval = 30
    @Published var lookRemaining: TimeInterval = 20 * 60

    private var timer: Timer?

    // MARK: - Init
    private init() {
        loadSettings()
        isLoading = false
    }

    // MARK: - Persistence
    private func persist<T>(_ value: T, _ key: String) {
        guard !isLoading else { return }
        UserDefaults.standard.set(value, forKey: key)
    }

    private func loadSettings() {
        let d = UserDefaults.standard

        blinkEnabled = d.object(forKey: Keys.blinkEnabled) as? Bool ?? true
        lookAwayEnabled = d.object(forKey: Keys.lookAwayEnabled) as? Bool ?? true

        allowInFullscreen = d.object(forKey: Keys.allowInFullscreen) as? Bool ?? true
        allowInVideoFullscreen = d.object(forKey: Keys.allowInVideoFullscreen) as? Bool ?? false
        allowDuringMeetings = d.object(forKey: Keys.allowDuringMeetings) as? Bool ?? false
        allowDuringDND = d.object(forKey: Keys.allowDuringDND) as? Bool ?? false

        blinkInterval = d.object(forKey: Keys.blinkInterval) as? TimeInterval ?? 30
        blinkDuration = d.object(forKey: Keys.blinkDuration) as? TimeInterval ?? 2

        lookInterval = d.object(forKey: Keys.lookInterval) as? TimeInterval ?? 20 * 60
        lookDuration = d.object(forKey: Keys.lookDuration) as? TimeInterval ?? 20

        blinkRemaining = blinkInterval
        lookRemaining = lookInterval
    }

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let blinkEnabled = "blinkEnabled"
        static let lookAwayEnabled = "lookAwayEnabled"

        static let allowInFullscreen = "allowInFullscreen"
        static let allowInVideoFullscreen = "allowInVideoFullscreen"
        static let allowDuringMeetings = "allowDuringMeetings"
        static let allowDuringDND = "allowDuringDND"

        static let blinkInterval = "blinkInterval"
        static let blinkDuration = "blinkDuration"

        static let lookInterval = "lookInterval"
        static let lookDuration = "lookDuration"
    }

    // MARK: - Lifecycle
    func start() {
        stop()

        blinkRemaining = blinkInterval
        lookRemaining = lookInterval

        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true
        )

        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Pause / Resume
    func pause(for duration: TimeInterval) {
        stop()
        isPaused = true
        pauseRemaining = duration

        pauseWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.resume()
        }

        pauseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    func resume() {
        pauseWorkItem?.cancel()
        pauseWorkItem = nil

        isPaused = false
        pauseRemaining = 0
        start()
    }

    // MARK: - Tick Logic
    @objc private func tick() {

        if isPaused {
            pauseRemaining -= 1
            if pauseRemaining <= 0 {
                resume()
            }
            return
        }

        if blinkEnabled {
            blinkRemaining -= 1
            if blinkRemaining <= 0 {
                triggerBlink()
                blinkRemaining = blinkInterval
            }
        }

        if lookAwayEnabled {
            lookRemaining -= 1
            if lookRemaining <= 0 {
                triggerLookAway()
                lookRemaining = lookInterval
            }
        }
    }

    // MARK: - Context Check
    private func isAllowedToShowReminder() -> Bool {
        let context = ContextDetector.shared

        if !allowInFullscreen && context.isFullscreenApp() {
            return false
        }

        if !allowInVideoFullscreen && context.isVideoPlayback() {
            return false
        }

        if !allowDuringMeetings && context.isMeetingOrCall() {
            return false
        }

        return true
    }

    // MARK: - Triggers
    private func triggerBlink() {
        guard isAllowedToShowReminder() else { return }

        NotchOverlayWindow.shared.show(
            duration: blinkDuration,
            mode: .blink
        )
    }

    private func triggerLookAway() {
        guard isAllowedToShowReminder() else { return }

        NotchOverlayWindow.shared.show(
            duration: lookDuration,
            mode: .lookAway
        )
    }
}
