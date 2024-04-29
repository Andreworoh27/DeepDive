//
//  SoundManager.swift
//  DeepDive
//
//  Created by Muhammad Rasyad Caesarardhi on 29/04/24.
//

import AVFoundation

class SoundManager {
    static var audioPlayer: AVAudioPlayer?
    static var audioQueue = DispatchQueue(label: "AudioQueue")
    static var isSoundPlaying = false

    static func playSound(_ soundFile: String) {
        guard let soundURL = Bundle.main.url(forResource: soundFile, withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1 // Play on repeat
            audioPlayer?.play()
            isSoundPlaying = true
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    static func stopSound() {
        audioPlayer?.stop()
        isSoundPlaying = false
    }
}

