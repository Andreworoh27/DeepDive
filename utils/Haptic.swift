import CoreHaptics

class Utils {
    static var engine: CHHapticEngine?

    static func runHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device does not support haptics")
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)

            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Error creating haptic engine: \(error)")
        }
    }

    static func runHapticOnMainThread() {
        DispatchQueue.main.async {
            runHaptic()
        }
    }

    static func runHapticOnBackgroundThread() {
        DispatchQueue.global().async {
            runHaptic()
        }
    }
}

// Example usage:
// Utils.runHapticOnMainThread() // Dispatches the haptic function to the main thread
// Utils.runHapticOnBackgroundThread() // Dispatches the haptic function to a background thread
