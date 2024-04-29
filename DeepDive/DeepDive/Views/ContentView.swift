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
    
    @State private var currentOxygen: CGFloat = 100
    @State private var isGameFinished: Bool = false
    
    var gameScene: GameScene
    init(){
        gameScene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        gameScene.currentOxygenLevel = 100
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing){
//                Text("Gyro Status: \(gyroInfo)  \(gyro.x) \(gyro.y)")
//                Text("Player position x: \(gameScene.playerNode.position.x) y: \(gameScene.playerNode.position.y)")
                SpriteView(scene: gameScene)
                    .onReceive(gameScene.$currentOxygenLevel, perform: { _ in
                        currentOxygen = gameScene.currentOxygenLevel
                    })
                    .onReceive(gameScene.$gameFinish, perform: { _ in
                        isGameFinished = true
                    })
                OxygenBar(current: $currentOxygen, max: .constant(100))
                    .padding(.trailing, 30)
                    .padding(.top, 50)
            }
            .navigationDestination(isPresented: $isGameFinished) {
                EndingScene(isGameFinished: $isGameFinished)
            }
            .onAppear(){
                if isGameFinished == true {
                    isGameFinished = false
                }
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
