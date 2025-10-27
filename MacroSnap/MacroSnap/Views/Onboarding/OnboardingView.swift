//
//  OnboardingView.swift
//  MacroSnap
//
//  First-launch onboarding tutorial
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Dark grey background (matches app default theme)
            Color(red: 0.13, green: 0.13, blue: 0.14).ignoresSafeArea()

            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: completeOnboarding) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 10)
                }

                // Pages
                TabView(selection: $currentPage) {
                    // Page 1: Welcome with Triple Rings
                    WelcomePageView(onGetStarted: completeOnboarding)
                        .tag(0)

                    // Page 2: Quick Logging
                    RingOnboardingPage(
                        iconType: .plus,
                        title: "Quick Logging",
                        description: "Tap + to log your macros in seconds. Just enter protein, carbs, and fat.",
                        primaryColor: .blue,
                        progress: 0.65
                    )
                    .tag(1)

                    // Page 3: Siri Shortcuts
                    RingOnboardingPage(
                        iconType: .mic,
                        title: "Use Your Voice",
                        description: "Say 'Hey Siri, log macros in MacroSnap' and Siri will ask for your numbers. Hands-free tracking!",
                        primaryColor: .cyan,
                        progress: 0.80
                    )
                    .tag(2)

                    // Page 4: Set Goals
                    RingOnboardingPage(
                        iconType: .target,
                        title: "Set Your Goals",
                        description: "Define your daily macro targets and track progress with beautiful rings.",
                        primaryColor: .orange,
                        progress: 0.85
                    )
                    .tag(3)

                    // Page 5: View History
                    RingOnboardingPage(
                        iconType: .calendar,
                        title: "Track Your Progress",
                        description: "View your history, weekly stats, and streak. All synced with iCloud.",
                        primaryColor: .green,
                        progress: 0.75
                    )
                    .tag(4)

                    // Page 6: Pro Features
                    RingOnboardingPage(
                        iconType: .star,
                        title: "Unlock Pro",
                        description: "Get unlimited history, themes, notes, presets, and advanced analytics.",
                        primaryColor: .purple,
                        progress: 1.0,
                        isLastPage: true,
                        onGetStarted: completeOnboarding
                    )
                    .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }

    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Welcome Page with Triple Rings

struct WelcomePageView: View {
    var onGetStarted: (() -> Void)?

    @State private var outerProgress: CGFloat = 0.0
    @State private var middleProgress: CGFloat = 0.0
    @State private var innerProgress: CGFloat = 0.0

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Triple concentric rings (matching app icon)
            ZStack {
                // Outer ring - Blue (Protein)
                Circle()
                    .trim(from: 0, to: outerProgress)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))

                // Middle ring - Orange (Carbs)
                Circle()
                    .trim(from: 0, to: middleProgress)
                    .stroke(
                        Color.orange,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))

                // Inner ring - Green (Fat)
                Circle()
                    .trim(from: 0, to: innerProgress)
                    .stroke(
                        Color.green,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                // Center dots (like app icon)
                VStack(spacing: 4) {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 4, height: 4)
                }
            }
            .shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 10)
            .onAppear {
                startAnimations()
            }

            // Title
            Text("Welcome to\nMacroSnap")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Tagline
            Text("The 2-Second Macro Tracker")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.cyan)
                .multilineTextAlignment(.center)
                .padding(.top, -8)

            // Description
            Text("Track your daily macros with beautiful rings. No meal tracking. No exercise logs. Just macros.")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
                .padding(.top, 8)

            Spacer()

            // Swipe hint
            Text("Swipe to continue →")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 60)
        }
    }

    private func startAnimations() {
        // Animate outer ring (Blue - Protein)
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            outerProgress = 0.85
        }

        // Animate middle ring (Orange - Carbs) with delay
        withAnimation(.easeInOut(duration: 2.2).delay(0.3).repeatForever(autoreverses: true)) {
            middleProgress = 0.70
        }

        // Animate inner ring (Green - Fat) with delay
        withAnimation(.easeInOut(duration: 2.4).delay(0.6).repeatForever(autoreverses: true)) {
            innerProgress = 0.60
        }
    }
}

// MARK: - Ring-Based Onboarding Page

enum OnboardingIconType {
    case plus, mic, widgets, target, calendar, star

    var systemName: String {
        switch self {
        case .plus: return "plus.circle.fill"
        case .mic: return "mic.fill"
        case .widgets: return "square.grid.2x2.fill"
        case .target: return "target"
        case .calendar: return "calendar"
        case .star: return "star.fill"
        }
    }
}

struct RingOnboardingPage: View {
    let iconType: OnboardingIconType
    let title: String
    let description: String
    let primaryColor: Color
    let progress: CGFloat
    var isLastPage: Bool = false
    var onGetStarted: (() -> Void)?

    @State private var animatedProgress: CGFloat = 0.0

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Ring with icon
            ZStack {
                // Progress ring
                Circle()
                    .stroke(primaryColor.opacity(0.2), lineWidth: 16)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        primaryColor,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))

                // Icon in center
                Image(systemName: iconType.systemName)
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundColor(primaryColor)
            }
            .shadow(color: primaryColor.opacity(0.3), radius: 25, x: 0, y: 10)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animatedProgress = progress
                }
            }

            // Title
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Description
            Text(description)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)

            Spacer()

            // Get Started button (only on last page)
            if isLastPage {
                Button(action: { onGetStarted?() }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: primaryColor.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            } else {
                // Hint to swipe
                Text("Swipe to continue →")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
}
