//
//  GameScene.swift
//  DeepDive
//
//  Created by Hans Arthur Cupiterson on 25/04/24.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    var sceneWidth : SKLabelNode!
    var sceneHeight :SKLabelNode!
    var mapNode : SKSpriteNode!
    var playerNode : SKSpriteNode!
    var cameraNode : SKCameraNode!
    var section2LimitNode : SKSpriteNode!
    var section3LimitNode : SKSpriteNode!
    var mapDivider : SKSpriteNode!
    var xLimiter : SKSpriteNode!
    var yLimiter : SKSpriteNode!

    var sharkTraps : Bool = false
    var bombTraps : Bool = false
    
    func initializeObjects(){
        //testing nodes
        sceneWidth = SKLabelNode(text: "width : \(size.width)")
        sceneWidth.position = CGPoint(x: size.width/2, y: size.height/2)
        
        sceneHeight = SKLabelNode(text: "height : \(size.height)")
        sceneHeight.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        
        addChild(sceneWidth)
        addChild(sceneHeight)
        
        
        // map nodes
        mapNode = SKSpriteNode(texture: SKTexture(imageNamed: "Map"))
        mapNode.position = CGPoint(x: 0, y: 0)
        
        playerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: 50, height: 100))
        playerNode.position = CGPoint(x: 0, y: mapNode.position.y + (mapNode.size.height/2) - (mapNode.size.height * 0.1))
        //        playerNode.position = CGPoint(x: 0, y: 0)
        
        
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y)
        cameraNode.setScale(1.5)
        
        section2LimitNode = SKSpriteNode(color: UIColor.red, size: CGSize(width: mapNode.size.width, height: 10))
        section2LimitNode.position = CGPoint(x: 0, y: section2)
        
        section3LimitNode = SKSpriteNode(color: UIColor.orange, size: CGSize(width: mapNode.size.width, height: 10))
        section3LimitNode.position = CGPoint(x: 0, y: section3)
        
        mapDivider =  SKSpriteNode(color: UIColor.green, size: CGSize(width: 10, height: mapNode.size.height))
        mapDivider.position = CGPoint (x: mapNode.position.x / 2, y : 0)
        
        xLimiter = SKSpriteNode(color: UIColor.cyan, size: CGSize(width: mapNode.size.width, height: 10))
        xLimiter.position = CGPoint(x: 0, y: 0)
        
        yLimiter = SKSpriteNode(color: UIColor.cyan, size: CGSize(width: 10, height: mapNode.size.height))
        yLimiter.position = CGPoint(x: 0, y: 0)
        
        addChild(mapNode)
        addChild(playerNode)
        addChild(cameraNode)
        addChild(section2LimitNode)
        addChild(section3LimitNode)
        //        addChild(mapDivider)
        //        addChild(xLimiter)
        //        addChild(yLimiter)
        //        print("map width : \(mapNode.size.width)")
        
        //        print("player location \(playerNode.position.x),\(playerNode.position.y)")
        
        
    }
    
    override func didMove(to view: SKView) {
        initializeObjects()
        self.camera = cameraNode
        backgroundColor = SKColor.blueSky
    }
    
    override func update(_ currentTime: TimeInterval) {
        // zone checker
        if(playerNode.position.y <= section2LimitNode.position.y && sharkTraps == false){
            sharkTraps = true
            print("Shark Traps on : \(sharkTraps.description)")
            
            let intervalDuration = SKAction.wait(forDuration: 3)
            let addSharkAction = SKAction.run {
                self.addSharks()
            }
            let sequenceAction = SKAction.sequence([intervalDuration, addSharkAction])
            let repeatAction = SKAction.repeatForever(sequenceAction)
            self.run(repeatAction)

        }
        else if (playerNode.position.y > section2LimitNode.position.y && sharkTraps == true){
            sharkTraps = false
            print("Shark Traps off : \(sharkTraps.description)")
        }
        
        if(playerNode.position.y <= section3LimitNode.position.y && bombTraps == false){
            bombTraps = true
            print("Bomb Traps on : \(bombTraps.description)")
        }
        else if(playerNode.position.y > section3LimitNode.position.y && bombTraps == true){
            bombTraps = false
            print("Bomb Traps off : \(bombTraps.description)")
        }
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
        
        let newX = playerNode.position.x + movementXDistance
        let newY = playerNode.position.y + movementYDistance
        
        // conditional to check so that the player won't go over boundary of the map
        if newX + playerNode.size.width / 2 <= frame.maxX && newX - playerNode.size.width / 2 >= frame.minX {
            playerNode.position.x = newX
        }
        
        if newY + playerNode.size.height / 2 <= frame.maxY && newY - playerNode.size.height / 2 >= frame.minY {
            playerNode.position.y = newY
        }
        
        cameraNode.position = playerNode.position
    }
    
    func addSharks(){
        let sharkImage = getRandomString()
        
        let directionRight = sharkImage.contains("Right") ? true : false
        
        let sharkNode = SKSpriteNode(imageNamed: sharkImage)
        
        //shark Y coordinate spawn location
        let sharkYPositon = random(
            min: (bombTraps ? section3LimitNode.position.y - sharkNode.size.height : section2LimitNode.position.y - sharkNode.size.height),
            max: bombTraps ? mapBottomSide + sharkNode.size.height : section3LimitNode.position.y + sharkNode.size.height
        )
        
        let sharkXPosition = directionRight ? mapLeftSide - sharkNode.size.width : mapRightSide + sharkNode.size.width
        
        sharkNode.position = CGPoint(
            x: sharkXPosition,
            y: sharkYPositon)
        
        addChild(sharkNode)
        
        let sharkSpeed = random(min: CGFloat(8), max: CGFloat(15))
        
        
        let sharkYDestination = random(
            min: section2LimitNode.position.y - sharkNode.size.height,
            max: (mapBottomSide + sharkNode.size.height)
        )
        
        // shark movement
        let actionMove = SKAction.move(
            to: CGPoint(
                x: directionRight ? mapRightSide + sharkNode.size.width : mapLeftSide - sharkNode.size.width,
                y: sharkYDestination
            ),
            duration: TimeInterval(sharkSpeed)
        )
        let actionDissapear = SKAction.removeFromParent()
        
        sharkNode.run(SKAction.sequence([actionMove,actionDissapear]))
        
    }
}
