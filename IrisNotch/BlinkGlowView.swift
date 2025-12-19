//
//  BlinkGlowView.swift
//  IrisNotch
//
//  Created by Sabarish G on 19/12/25.
//
import SwiftUI

struct BlinkGlowView: View {

    @State private var animate = false

    private let pillWidth: CGFloat = 360
    private let pillHeight: CGFloat = 36

    var body: some View {
        ZStack {

            // 🌊 Outer colorful glow (diffused)
            Capsule()
                .fill(Color.clear)
                .shadow(
                    color: Color(red: 0.4, green: 0.8, blue: 1.0).opacity(animate ? 0.55 : 0.35),
                    radius: animate ? 42 : 26,
                    y: animate ? 14 : 8
                )
                .shadow(
                    color: Color(red: 0.8, green: 0.6, blue: 1.0).opacity(animate ? 0.45 : 0.25),
                    radius: animate ? 34 : 20
                )
                .frame(width: pillWidth, height: pillHeight)

            // 🌈 Base gradient (cool tones)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.35, green: 0.85, blue: 1.0),
                            Color(red: 0.45, green: 0.75, blue: 1.0),
                            Color(red: 0.55, green: 0.7, blue: 0.95)
                        ],
                        startPoint: animate ? .leading : .trailing,
                        endPoint: animate ? .trailing : .leading
                    )
                )
                .frame(width: pillWidth, height: pillHeight)
                .blur(radius: 8)

            // 🌸 Secondary warm blend (very subtle)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.6, blue: 0.85).opacity(0.35),
                            Color(red: 0.9, green: 0.7, blue: 1.0).opacity(0.25),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: pillWidth, height: pillHeight)
                .blur(radius: 10)
                .blendMode(.plusLighter)

            // ✨ Soft white core (Apple secret sauce)
            Capsule()
                .fill(Color.white.opacity(0.12))
                .frame(width: pillWidth * 0.85, height: pillHeight * 0.6)
                .blur(radius: 6)

            // 👁️ Eyes (clear, readable)
            HStack {
                Text("👁️")
                Spacer()
                Text("👁️")
            }
            .font(.system(size: 24))
            .padding(.horizontal, 24)
            .frame(width: pillWidth, height: pillHeight)
        }
        .frame(width: pillWidth, height: pillHeight)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.4)
                .repeatCount(2, autoreverses: true)
            ) {
                animate.toggle()
            }
        }
    }
}
