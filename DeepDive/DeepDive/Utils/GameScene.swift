//
//  GameScene.swift
//  DeepDive
//
//  Created by Hans Arthur Cupiterson on 25/04/24.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    var mapSize: CGSize = CGSize()
    var player = SKSpriteNode(color: SKColor.brown, size: CGSize(width: 50, height: 20))
    var cameraNode = SKCameraNode()
    let cameraZoom: CGFloat = 0.2
    var backgroundNode = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        // init
        self.backgroundNode = SKSpriteNode(texture: SKTexture(imageNamed: "MapBackground"))
        self.mapSize = backgroundNode.size
        self.size = mapSize
        
        // add camera
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        cameraNode.xScale = cameraZoom
        cameraNode.yScale = cameraZoom
        addChild(cameraNode)
        self.camera = cameraNode
        
        // put map
        self.backgroundColor = .gray
        backgroundNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(backgroundNode)
        
        // disable gravity
        physicsWorld.gravity = CGVector.zero
        
        // init player
        let playerSize = CGSize(width: 50, height: 20)
        player.physicsBody = SKPhysicsBody(rectangleOf: playerSize)
        player.physicsBody?.allowsRotation = false
        player.size = playerSize
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(player)
    }
    
    func movePlayer(dx: CGFloat, dy: CGFloat) {
        // limit gyro movement so that it won't move very fast
        var movementX = dx
        if movementX < -1 {
            movementX = -0.9
        } else if movementX > 1 {
            movementX = 0.9
        }
        
        var movementY = dy
        if movementY < -1 {
            movementY = -0.9
        } else if movementY > 1 {
            movementY = 0.9
        }
        
        // calculate movement speed
        let movementFactor: CGFloat = 50 // adjust this factor to control the movement speed
        let movementXDistance = movementX * movementFactor
        let movementYDistance = movementY * movementFactor * -1
        
        let newX = player.position.x + movementXDistance
        let newY = player.position.y + movementYDistance
        
        // conditional to check so that the player won't go over boundary of the map
        if newX + player.size.width / 2 <= frame.maxX && newX - player.size.width / 2 >= frame.minX {
            player.position.x = newX
        }
        
        if newY + player.size.height / 2 <= frame.maxY && newY - player.size.height / 2 >= frame.minY {
            player.position.y = newY
        }
        
        cameraNode.position = player.position
    }
}
