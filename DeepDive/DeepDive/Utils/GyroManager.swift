//
//  GyroManager.swift
//  DeepDive
//
//  Created by Hans Arthur Cupiterson on 25/04/24.
//

import Foundation
import CoreMotion

class GyroManager: ObservableObject {
    private let manager = CMMotionManager()
    @Published var x = 0.0
    @Published var y = 0.0
    
    private init(){
        manager.deviceMotionUpdateInterval = 1/30
        
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let motion = data?.attitude else {
                return
            }
            
            DispatchQueue.main.async {
                self?.x = motion.roll
                self?.y = motion.pitch
            }
        }
    }

    static let shared = GyroManager()
}
