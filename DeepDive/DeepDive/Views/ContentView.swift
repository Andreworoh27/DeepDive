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
    
    var gameScene: GameScene
    init(){
        gameScene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
    var body: some View {
        VStack {
            ZStack{
//                Text("Gyro Status: \(gyroInfo)  \(gyro.x) \(gyro.y)")
//                Text("Player position x: \(gameScene.playerNode.position.x) y: \(gameScene.playerNode.position.y)")
                SpriteView(scene: gameScene)
            }
        }
        .ignoresSafeArea()
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
