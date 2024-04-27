//
//  GameScene.swift
//  DeepDive
//
//  Created by Hans Arthur Cupiterson on 25/04/24.
//

import Foundation
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
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
    var gyro = GyroManager.shared

    var sharkTraps : Bool = false
    var bombTraps : Bool = false
    var sharkInSection2 : Bool = true
    
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
        mapNode.physicsBody = SKPhysicsBody(edgeLoopFrom: mapNode.frame)
        mapNode.physicsBody?.contactTestBitMask = 1
        
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2 {
            // Player collided with the border
            let player = contact.bodyA.node as! SKSpriteNode
            let border = contact.bodyB.node as! SKSpriteNode
            player.position = (scene?.convert(player.position, from: border))!
        }
    }
    
    override func didMove(to view: SKView) {
        initializeObjects()
        self.camera = cameraNode
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: mapNode.frame)
        self.physicsWorld.contactDelegate = self
        backgroundColor = SKColor.blueSky
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        self.movePlayer(dx: location.x, dy: location.y)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //zone checker for section 1
        if(playerNode.position.y > section2LimitNode.position.y){
            // turn on shark trap
            if(!sharkTraps){
                sharkInSection2 = true
                sharkTraps = true
                print("Shark Traps on : \(sharkTraps.description)")
                
                let intervalDuration = SKAction.wait(forDuration: 3)
                let addSharkAction = SKAction.run {
                    self.addSharks()
                }
                let sequenceAction = SKAction.sequence([intervalDuration, addSharkAction])
                let repeatAction = SKAction.repeatForever(sequenceAction)
                self.run(repeatAction, withKey: "SharkSpawnAction")
            }
            
            // turn of bomb trap
            if(bombTraps){
                bombTraps = false
                print("Bomb Traps off : \(bombTraps.description)")
                removeBombsFromSection3()
            }
            
            // count oxigen
            oxigenSection1()
        }
        
        // zone checker for section 2
        if(playerNode.position.y <= section2LimitNode.position.y){
            sharkInSection2 = true
            if(!bombTraps){
                // turn on bomb trap
                bombTraps = true
                print("Bomb Traps on : \(bombTraps.description)")
                
                let addBombAction = SKAction.run {
                    self.addBombs()
                }
                
                let repeatAction = SKAction.repeat(addBombAction, count: 10)
                self.run(repeatAction)
            }
            
            // count oxigen
            oxigenSection2()
        }
        else if (playerNode.position.y > section2LimitNode.position.y){
////            turn off shark trap
//            sharkTraps = false
//            print("Shark Traps off : \(sharkTraps.description)")
//            self.removeAction(forKey: "SharkSpawnAction")
        }
        
        // zone checker for section 3
        if(playerNode.position.y <= section3LimitNode.position.y){
            sharkInSection2 = false
            
            // count oxigen
            oxigenSection3()
        }
        else if(playerNode.position.y > section3LimitNode.position.y){

        }
        
        movePlayer(dx: gyro.x, dy: gyro.y)
    }
    
    func movePlayer(dx: CGFloat, dy: CGFloat) {
        // limit gyro movement so that it won't move very fast
        var movementX = dx
        if movementX < -0.5 {
            movementX = -0.5
        } else if movementX > 0.5 {
            movementX = 0.5
        }
        
        var movementY = dy
        if movementY < 0 {
            movementY *= 3
        }
        else if movementY > 0.3 {
            movementY = 0.3
        }
        
        // calculate movement speed
        let movementFactor: CGFloat = 10 // adjust this factor to control the movement speed
        let movementXDistance = movementX * movementFactor
        let movementYDistance = movementY * movementFactor * -1
        
        let newX = playerNode.position.x + movementXDistance
        let newY = playerNode.position.y + movementYDistance
        
        // conditional to check so that the player won't go over boundary of the map
        if newX + playerNode.size.width / 2 <= mapNode.frame.maxX && newX - playerNode.size.width / 2 >= mapNode.frame.minX {
            playerNode.position.x = newX
        }
        
        if newY + playerNode.size.height / 2 <= mapNode.frame.maxY && newY - playerNode.size.height / 2 >= mapNode.frame.minY {
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
            min: sharkInSection2 ? section2LimitNode.position.y - sharkNode.size.height : section3LimitNode.position.y - sharkNode.size.height,
            max: sharkInSection2 ? section3LimitNode.position.y + sharkNode.size.height : mapBottomSide + sharkNode.size.height
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
    
    func addBombs(){
        let bombNode = SKSpriteNode(imageNamed: bomb)
        
        let bombYPosition = random(
            min: section3LimitNode.position.y - bombNode.size.height,
            max: mapBottomSide + bombNode.size.height)
        
        let bombXPosition  = random(
            min: mapLeftSide + bombNode.size.width,
            max: mapRightSide - bombNode.size.width)
        
        bombNode.position = CGPoint(
            x : bombXPosition,
            y : bombYPosition)
        
        addChild(bombNode)
    }
    
    
    func removeBombsFromSection3() {
        // Iterate through all child nodes
        for node in self.children {
            // Check if the node is a bomb and located in section 3
            if let bombNode = node as? SKSpriteNode, bombNode.name == "Bomb" {
                if bombNode.position.y <= section3LimitNode.position.y {
                    // Remove the bomb from the scene
                    bombNode.removeFromParent()
                }
            }
        }
    }
    
    // for counting oxigen decreasse in section 1
    func oxigenSection1(){
    }
    
    // for counting oxigen decreasse in section 2
    func oxigenSection2(){
        
    }
    
    // for counting oxigen decreasse in section 3
    func oxigenSection3(){
        
    }
}
