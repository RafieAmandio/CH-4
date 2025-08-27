import UIKit
import CoreHaptics

// MARK: - Haptic Types
enum HapticFeedbackType {
    // Impact Feedback
    case light
    case medium
    case heavy
    case soft      // iOS 13+
    case rigid     // iOS 13+
    
    // Notification Feedback
    case success
    case warning
    case error
    
    // Selection Feedback
    case selection
    
    // Custom Core Haptics
    case custom(intensity: Float, sharpness: Float)
    case heartbeat
    case tick
    case bounce
    case longPress
}

// MARK: - Haptic Manager
final class HapticManager {
    
    // MARK: - Singleton
    static let shared = HapticManager()
    
    // MARK: - Properties
    private var supportsHaptics: Bool {
        return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    private var hapticEngine: CHHapticEngine?
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - Settings
    var isHapticEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "haptic_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "haptic_enabled") }
    }
    
    // MARK: - Initialization
    private init() {
        setupHapticEngine()
        prepareHapticGenerators()
        
        // Default to enabled
        if UserDefaults.standard.object(forKey: "haptic_enabled") == nil {
            isHapticEnabled = true
        }
    }
    
    // MARK: - Setup
    private func setupHapticEngine() {
        guard supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            // Handle engine stopping
            hapticEngine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason)")
                self?.restartEngine()
            }
            
            // Handle engine reset
            hapticEngine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                self?.restartEngine()
            }
            
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    private func prepareHapticGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    private func restartEngine() {
        do {
            try hapticEngine?.start()
        } catch {
            print("Failed to restart haptic engine: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func trigger(_ type: HapticFeedbackType) {
        guard isHapticEnabled else { return }
        
        switch type {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .soft:
            impactSoft.impactOccurred()
        case .rigid:
            impactRigid.impactOccurred()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        case .selection:
            selectionGenerator.selectionChanged()
        case .custom(let intensity, let sharpness):
            playCustomHaptic(intensity: intensity, sharpness: sharpness)
        case .heartbeat:
            playHeartbeatPattern()
        case .tick:
            playTickPattern()
        case .bounce:
            playBouncePattern()
        case .longPress:
            playLongPressPattern()
        }
    }
    
    // MARK: - Custom Haptic Patterns
    private func playCustomHaptic(intensity: Float, sharpness: Float) {
        guard supportsHaptics, let engine = hapticEngine else {
            // Fallback to impact feedback
            impactMedium.impactOccurred()
            return
        }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic: \(error)")
        }
    }
    
    private func playHeartbeatPattern() {
        guard supportsHaptics, let engine = hapticEngine else {
            impactMedium.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impactMedium.impactOccurred()
            }
            return
        }
        
        let events = [
            CHHapticEvent(eventType: .hapticTransient,
                         parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                         ],
                         relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient,
                         parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                         ],
                         relativeTime: 0.1)
        ]
        
        playPattern(events: events)
    }
    
    private func playTickPattern() {
        guard supportsHaptics, let engine = hapticEngine else {
            selectionGenerator.selectionChanged()
            return
        }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0
        )
        
        playPattern(events: [event])
    }
    
    private func playBouncePattern() {
        guard supportsHaptics, let engine = hapticEngine else {
            impactLight.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.impactLight.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impactLight.impactOccurred()
            }
            return
        }
        
        let events = [
            CHHapticEvent(eventType: .hapticTransient,
                         parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                         ],
                         relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient,
                         parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                         ],
                         relativeTime: 0.05),
            CHHapticEvent(eventType: .hapticTransient,
                         parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                         ],
                         relativeTime: 0.1)
        ]
        
        playPattern(events: events)
    }
    
    private func playLongPressPattern() {
        guard supportsHaptics, let engine = hapticEngine else {
            impactMedium.impactOccurred()
            return
        }
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0,
            duration: 0.3
        )
        
        playPattern(events: [event])
    }
    
    private func playPattern(events: [CHHapticEvent]) {
        guard let engine = hapticEngine else { return }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
    
    // MARK: - Convenience Methods
    func impactOccurred(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticEnabled else { return }
        
        switch style {
        case .light: trigger(.light)
        case .medium: trigger(.medium)
        case .heavy: trigger(.heavy)
        case .soft: trigger(.soft)
        case .rigid: trigger(.rigid)
        @unknown default: trigger(.medium)
        }
    }
    
    func notificationOccurred(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticEnabled else { return }
        
        switch type {
        case .success: trigger(.success)
        case .warning: trigger(.warning)
        case .error: trigger(.error)
        @unknown default: trigger(.warning)
        }
    }
    
    func selectionChanged() {
        trigger(.selection)
    }
}

// MARK: - SwiftUI Extensions
import SwiftUI

extension View {
    func hapticFeedback(_ type: HapticFeedbackType, onTap: Bool = true) -> some View {
        self.onTapGesture {
            if onTap {
                HapticManager.shared.trigger(type)
            }
        }
    }
    
    func hapticOnAppear(_ type: HapticFeedbackType) -> some View {
        self.onAppear {
            HapticManager.shared.trigger(type)
        }
    }
    
    func hapticOnChange<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        self.onChange(of: value) { newValue in
            HapticManager.shared.trigger(.selection)
            action(newValue)
        }
    }
}

// MARK: - Button Extensions
extension Button {
    func withHapticFeedback(_ type: HapticFeedbackType = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                HapticManager.shared.trigger(type)
            }
        )
    }
}

// MARK: - Usage Examples
/*
Basic Usage:
HapticManager.shared.trigger(.medium)
HapticManager.shared.trigger(.success)
HapticManager.shared.trigger(.custom(intensity: 0.8, sharpness: 0.5))

SwiftUI Usage:
Button("Tap me") { }
    .withHapticFeedback(.medium)

Text("Hello")
    .hapticOnAppear(.light)

Toggle("Setting", isOn: $setting)
    .hapticOnChange(of: setting) { _ in }
*/
