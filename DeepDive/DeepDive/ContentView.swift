//
//  ContentView.swift
//  DivingGame
//
//  Created by Hans Arthur Cupiterson on 25/04/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var gyro = GyroManager.shared
    @State private var curr: Double = 0
    @State private var gyroInfo: String = "Inactive"
    @State private var isButtonPressed: Bool = false
    
    var scene: GameScene
    init(){
        scene = GameScene()
        scene.scaleMode = .fill
    }
    
    var body: some View {
        VStack {
            Text("Gyro Status: \(gyroInfo)  \(gyro.x) \(gyro.y)")
            Text("Player position x: \(scene.player.position.x) y: \(scene.player.position.y)")
            SpriteView(scene: scene)
        }
        .onChange(of: [gyro.x, gyro.y]) {
            checkSideMove()
            scene.movePlayer(dx: gyro.x, dy: gyro.y)
        }
    }
    
    func checkSideMove(){
        if gyro.x < 0{
            gyroInfo = "Left"
        } else {
            gyroInfo = "Right"
        }
        curr = gyro.x
    }
    
}

#Preview {
    ContentView()
}
