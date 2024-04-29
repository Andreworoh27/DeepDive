//
//  GameScene.swift
//  DeepDive
//
//  Created by Hans Arthur Cupiterson on 25/04/24.
//

import Foundation
import SpriteKit

class GameScene: SKScene{
    
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
    var portalNode : SKSpriteNode!
    
    var initLocation: CGPoint!
    var gyro = GyroManager.shared
    
    var oxygenBarNode: SKSpriteNode!
    @Published var currentOxygenLevel: CGFloat!
    var maxOxygenLevel: CGFloat!
    var oxygenDecreaseInterval: CGFloat!
    var lastSavedOxygenTime: TimeInterval!
    
    var lastHapticTime: TimeInterval!
    var intervalHapticDelay: CGFloat!
    
    var sharkTraps : Bool = false
    var bombTraps : Bool = false
    var sharkInSection2 : Bool = true
    var portalSpawn : Bool = false
    var bombCount : Int = 0
    
    var userEnteredThePortal: Bool = false
    @Published var gameFinish: Bool = false
    
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
        
        // init Starting Location
        initLocation = CGPoint(x: 0, y: mapNode.position.y + (mapNode.size.height/2) - (mapNode.size.height * 0.1) + 100)
//        initLocation = CGPoint(x: 0, y: mapNode.position.y)
        
        playerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: 50, height: 100))
        playerNode.position = initLocation
        //        playerNode.position = CGPoint(x: 0, y: 0)
        //setup player physics
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerNode.size)
        playerNode.physicsBody?.isDynamic = true
        playerNode.physicsBody?.categoryBitMask = PhysicsCategory.player
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.shark | PhysicsCategory.bomb
        playerNode.physicsBody?.collisionBitMask = PhysicsCategory.shark
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        
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
        
        initOxygen()
        
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
        self.physicsWorld.contactDelegate = self
        backgroundColor = SKColor.blueSky
        
        // set physics for the map
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        movePlayer(dx: location.x, dy: location.y)
    }
    
    override func update(_ currentTime: TimeInterval) {
//        runHapticOnBackgroundScene(currentTime)
        decreaseOxygen(currentTime)
        
        //zone checker for section 1
        if(playerNode.position.y > section2LimitNode.position.y){
            // turn on shark trap
            if(!sharkTraps){
                sharkInSection2 = true
                sharkTraps = true
//                print("Shark Traps on : \(sharkTraps.description)")
                
                // define shark spawn interval
                let intervalDuration = SKAction.wait(forDuration: 1.5)
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
//                print("Bomb Traps off : \(bombTraps.description)")
                removeBombsFromSection3()
            }
            
            // count oxigen
            oxigenSection1()
        }
        
        // zone checker for section 2
        if(playerNode.position.y <= section2LimitNode.position.y){
            sharkInSection2 = true
            if(!portalSpawn) {
                spawnPortal()
                portalSpawn = true
            }
            
            if(!bombTraps && portalSpawn){
                // turn on bomb trap
                bombTraps = true
//                print("Bomb Traps on : \(bombTraps.description)")
                
                let addBombAction = SKAction.run {
                    self.addBombs()
                }
                
                let repeatAction = SKAction.repeat(addBombAction, count: 30)
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
        
//        if portalNode != nil {
//            if(isPlayerAtTheMiddleOfThePortal(portalNode: portalNode, objectNode: playerNode)){
//                throwPlayerInsidePortalEvent()
//            }
//        }
    }
    
    func movePlayer(dx: CGFloat, dy: CGFloat) {
        // if user enter the portal, user can't move
        if userEnteredThePortal == true {
            return
        }
        
        // limit gyro movement so that it won't move very fast
        var movementX = dx
        if movementX < -0.5 {
            movementX = -0.5
        } else if movementX > 0.5 {
            movementX = 0.5
        }
        
        var movementY = dy
        if movementY < 0 {
            movementY *= 2
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
    
    func addBubble(){
        let bubbleNode = SKSpriteNode(imageNamed: "Bubble")
        bubbleNode.size = CGSize(width: 20, height: 20)
        bubbleNode.name = "Bubble"
        bubbleNode.physicsBody?.isDynamic = false
        
        bubbleNode.position = playerNode.position
        
        let intervalDuration = SKAction.wait(forDuration: 3)
        let actionDissapear = SKAction.removeFromParent()
        
        addChild(bubbleNode)
        bubbleNode.run(SKAction.sequence([intervalDuration, actionDissapear]))
        HapticUtils.runHapticOnBackgroundThread()
    }
    
    func addSharks(){
        let sharkImage = getRandomString()
        
        let directionRight = sharkImage.contains("Right") ? true : false
        
        let sharkNode = SKSpriteNode(imageNamed: sharkImage)
        sharkNode.name = "Shark"
        
        //shark Y coordinate spawn location
        let sharkYPositon = random(
            min: sharkInSection2 ? section2LimitNode.position.y - sharkNode.size.height : section3LimitNode.position.y - sharkNode.size.height,
            max: sharkInSection2 ? section3LimitNode.position.y + sharkNode.size.height : mapBottomSide + sharkNode.size.height
        )
        
        let sharkXPosition = directionRight ? mapLeftSide - sharkNode.size.width : mapRightSide + sharkNode.size.width
        
        sharkNode.position = CGPoint(
            x: sharkXPosition,
            y: sharkYPositon)
        
        //setup shark physics
        sharkNode.physicsBody = SKPhysicsBody(rectangleOf: sharkNode.size) // 1
        sharkNode.physicsBody?.isDynamic = true // 2
        sharkNode.physicsBody?.categoryBitMask = PhysicsCategory.shark // 3
        sharkNode.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
        sharkNode.physicsBody?.collisionBitMask = PhysicsCategory.player // 5
        
        addChild(sharkNode)
        
        let sharkSpeed = random(min: CGFloat(5), max: CGFloat(10))
        
        
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
        
        bombNode.name = "Bomb"
        
        let bombYPosition = random(
            min: section3LimitNode.position.y - bombNode.size.height,
            max: mapBottomSide + bombNode.size.height)
        
        let bombXPosition  = random(
            min: mapLeftSide + bombNode.size.width,
            max: mapRightSide - bombNode.size.width)
        
        bombNode.position = CGPoint(
            x : bombXPosition,
            y : bombYPosition)
        
        while(isInPortalFrame(portalNode: portalNode, objectNode: bombNode)){
            let bombYPosition = random(
                min: section3LimitNode.position.y - bombNode.size.height,
                max: mapBottomSide + bombNode.size.height)
            
            let bombXPosition  = random(
                min: mapLeftSide + bombNode.size.width,
                max: mapRightSide - bombNode.size.width)
            
            bombNode.position = CGPoint(
                x : bombXPosition,
                y : bombYPosition)
        }
        
        //setup player physics
        bombNode.physicsBody = SKPhysicsBody(rectangleOf: bombNode.size)
        bombNode.physicsBody?.isDynamic = true
        bombNode.physicsBody?.categoryBitMask = PhysicsCategory.bomb
        bombNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
        bombNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        bombCount += 1
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
        bombCount = 0
    }
    
    func removeAllSharks(){
        for node in self.children {
            // check if the node is a shark
            if let sharkNode = node as? SKSpriteNode, sharkNode.name == "Shark" {
                sharkNode.removeFromParent()
            }
        }
    }
    
    // for counting oxigen decreasse in section 1
    func oxigenSection1(){
        oxygenDecreaseInterval = 1.5
        intervalHapticDelay = 10.0
    }
    
    // for counting oxigen decreasse in section 2
    func oxigenSection2(){
        oxygenDecreaseInterval = 1
        intervalHapticDelay = 5.0

    }
    
    // for counting oxigen decreasse in section 3
    func oxigenSection3(){
        oxygenDecreaseInterval = 0.5
        intervalHapticDelay = 3.0
    }
    
    func playerCollideWithObject(player: SKSpriteNode, object: SKSpriteNode) {
        if object.name == "Portal" {
            print("Player collied with portal")
            throwPlayerInsidePortalEvent()
            return
        }
        
        if object.name == "Bomb"{
            object.removeFromParent()
//            print("Hit Bomb")
            bombCount -= 1
            
            // logic when hit bomb
            if userEnteredThePortal == false {
                HapticUtils.runHapticOnHitBomb()
                currentOxygenLevel -= 50
            }

        }
        else if object.name == "Shark"{
//            print("Hit Shark")
            
            // logic when hit shark
            if userEnteredThePortal == false {
                HapticUtils.runHapticOnHitShark()
                currentOxygenLevel -= 25
            }
        }
        
        
        animateGettingHurt()
        
    }
    
    func spawnPortal(){
//        print("trigger spawn portal")
        // Create the portal node
        portalNode = SKSpriteNode(imageNamed: "Portal 1")
        portalNode.name = "Portal"
        portalNode.size = CGSize(width: 150, height: 250)
        
        portalNode.position = generatePortalPosition(portalNode: portalNode, section3LimitNode: section3LimitNode)
        //setup player physics
        portalNode.physicsBody = SKPhysicsBody(rectangleOf: portalNode.size)
        portalNode.physicsBody?.isDynamic = true
        portalNode.physicsBody?.categoryBitMask = PhysicsCategory.bomb
        portalNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
        portalNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(portalNode)
        
        // Create an array to hold SKTexture objects
        var portalTextures: [SKTexture] = []
        
        // Iterate over the array of image names and load them into SKTexture objects
        for imageName in portalImage {
            let texture = SKTexture(imageNamed: imageName)
            portalTextures.append(texture)
        }
        
        // Create an animation action
        let animatePortalAction = SKAction.animate(with: portalTextures, timePerFrame: 0.1)
        
        // Apply the animation to the portal node
        portalNode.run(SKAction.repeatForever(animatePortalAction),withKey: "PortalAnimation")
    }
    
    func runHapticOnBackgroundScene(_ currentTime: TimeInterval) {
        if lastHapticTime == nil {
            lastHapticTime = currentTime
        }
        
        
        else if abs(lastHapticTime - currentTime) >= intervalHapticDelay {
            HapticUtils.runHapticOnBackgroundThread()
            lastHapticTime = nil
        }
       
    }
    
    
    func initOxygen(){
        currentOxygenLevel = 100
        maxOxygenLevel = 100
        oxygenDecreaseInterval = 2
    }

    func decreaseOxygen(_ currentTime: TimeInterval){
        if currentOxygenLevel <= 0 {
            throwGameOverEvent()
        }
        
        if lastSavedOxygenTime == nil {
            lastSavedOxygenTime = currentTime
        }
        else {
            if abs(lastSavedOxygenTime - currentTime) >= oxygenDecreaseInterval && userEnteredThePortal == false {
                if currentOxygenLevel > 0 {
                    addBubble()
                    currentOxygenLevel -= 1
                    lastSavedOxygenTime = nil
                }
//                else {
//                    oxygenBarNode.removeFromParent()
//                }
//
//                oxygenBarNode.size = CGSize(width: oxygenBarNode.size.width, height: currentOxygenLevel)
//                if(currentOxygenLevel <= 100 && currentOxygenLevel > 75){
//                    oxygenBarNode.color = UIColor.green
//                }
//                else if(currentOxygenLevel <= 75 && currentOxygenLevel > 50){
//                    oxygenBarNode.color = UIColor.yellow
//                }
//                else if(currentOxygenLevel <= 50 && currentOxygenLevel > 25){
//                    oxygenBarNode.color = UIColor.orange
//                }
//                else if(currentOxygenLevel <= 25){
//                    oxygenBarNode.color = UIColor.red
//                }
//                print("Oxygen decreased: \(currentOxygenLevel ?? -1)")
            }
        }
    }
    
    func animateGettingHurt(){
        let delayAction = SKAction.wait(forDuration: 0.1)
        let animation1 = SKAction.run {
            self.playerNode.color = .red
            self.playerNode.setScale(1.1)
        }
        let animation2 = SKAction.run {
            self.playerNode.setScale(1)
            self.playerNode.color = .gray
        }
        let sequenceAction = SKAction.sequence([animation1, delayAction, animation2])
        playerNode.run(sequenceAction)
    }
    
    func animateEnterPortal() {
        let spiralPath = UIBezierPath()
        spiralPath.move(to: playerNode.position)
        
        let portalCenter = portalNode.position
        let radius = portalNode.size.width / 2
        var spiralRadius = radius * 1
        let spiralAngle = CGFloat.pi * 2
        
        for i in 0...30 {
            let angle = spiralAngle * CGFloat(i) / 45
            let x = portalCenter.x + cos(angle) * spiralRadius
            let y = portalCenter.y + sin(angle) * spiralRadius
            spiralPath.addLine(to: CGPoint(x: x, y: y))
            spiralRadius *= 0.9
        }
        
        spiralPath.addLine(to: portalCenter)
        
        let followPathAction = SKAction.follow(spiralPath.cgPath, asOffset: false, orientToPath: true, duration: 2)
        let fadeOutAction = SKAction.fadeOut(withDuration: 2)
        let removeAction = SKAction.removeFromParent()
        let setGameToFinishState = SKAction.run {
            self.gameFinish = true
            print("Game finish? \(self.gameFinish)")
        }
        
        // animation sequence
        let sequenceAction = SKAction.sequence([followPathAction, fadeOutAction, removeAction, setGameToFinishState])
        playerNode.run(sequenceAction)
        
    }
    
    func throwGameOverEvent(){
        playerNode.position = initLocation
        playerNode.zRotation = 0
        currentOxygenLevel = 100
    }
    
    func throwPlayerInsidePortalEvent(){
        cameraNode.position = portalNode.position
        userEnteredThePortal = true
        sharkTraps = false
        removeBombsFromSection3()
        removeAllSharks()
        
        animateEnterPortal()
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // get collided objects
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // define the collided object
        if ((firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.player == 0)) {
            if let player = firstBody.node as? SKSpriteNode,
               let object = secondBody.node as? SKSpriteNode {
                playerCollideWithObject(player: player, object: object)
            }
        }
    }
}
