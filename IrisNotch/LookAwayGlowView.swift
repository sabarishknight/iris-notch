//
//  LookAwayGlowView.swift
//  IrisNotch
//
//  Created by Sabarish G on 19/12/25.
//
import SwiftUI

struct LookAwayGlowView: View {

    @State private var animate = false

    private let pillWidth: CGFloat = 460
    private let pillHeight: CGFloat = 40

    var body: some View {
        ZStack {

            // 🌿 Soft outward glow (calmer than blink)
            Capsule()
                .fill(Color.clear)
                .shadow(
                    color: Color.green.opacity(animate ? 0.45 : 0.25),
                    radius: animate ? 42 : 26,
                    y: animate ? 14 : 8
                )
                .shadow(
                    color: Color.teal.opacity(animate ? 0.35 : 0.2),
                    radius: animate ? 32 : 20
                )
                .frame(width: pillWidth, height: pillHeight)

            // 🌈 Calm nature gradient
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.85, blue: 0.7),   // leaf green
                            Color(red: 0.55, green: 0.8, blue: 0.85),   // teal
                            Color(red: 0.6, green: 0.75, blue: 0.95)    // sky
                        ],
                        startPoint: animate ? .leading : .trailing,
                        endPoint: animate ? .trailing : .leading
                    )
                )
                .frame(width: pillWidth, height: pillHeight)
                .blur(radius: 10)

            // ✨ Soft white core (very subtle)
            Capsule()
                .fill(Color.white.opacity(0.08))
                .frame(width: pillWidth * 0.8, height: pillHeight * 0.6)
                .blur(radius: 8)

            // 👁️ 🌿 🪟 Emojis (meaningful + calm)
            HStack(spacing: 40) {
                Text("👁️")
                Text("🌿")
                Text("🪟")
            }
            .font(.system(size: 24))
            .frame(width: pillWidth, height: pillHeight)
        }
        .frame(width: pillWidth, height: pillHeight)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.8)   // slower than blink
                .repeatCount(1, autoreverses: true)
            ) {
                animate.toggle()
            }
        }
    }
}

