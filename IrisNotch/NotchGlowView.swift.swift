//
//  NotchGlowView.swift.swift
//  IrisNotch
//
//  Created by Sabarish G on 19/12/25.
//
import SwiftUI
import Combine


struct NotchGlowView: View {
    let mode: ReminderMode

    @State private var opacity: Double = 0.4
    private let timer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(mode == .blink ? Color.blue : Color.green.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .frame(width: 220, height: 36)
            .opacity(opacity)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = opacity == 1.0 ? 0.4 : 1.0
                }
            }
    }
}
