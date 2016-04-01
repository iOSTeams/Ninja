//
//  GameScene.swift
//  Ninja
//
//  Created by King Justin on 3/29/16.
//  Copyright (c) 2016 justinleesf. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerScoreLabel: SKLabelNode!
    
    var playerScore: Int = 0 {
        didSet {
            playerScoreLabel.text = "Score: \(playerScore)"
        }
    }
    
    //Speed of waterball
    let waterballVelocity = 300 //581 for boost
    
    let tapToPlay: SKSpriteNode = SKSpriteNode(imageNamed: "tapToPlay")

    var backgroundMusicPlayer = AVAudioPlayer()
    var boom = AVAudioPlayer()
    
    let ninjaCategory:UInt32 = 0x1 << 0
    let floorCategory:UInt32 = 0x1 << 1
    let SkyCategory:UInt32 = 0x1 << 2
    let waterballCategory:UInt32 = 0x1 << 3
    let fireballCategory:UInt32 = 0x1 << 4
    
    
    let ninjaCategoryName = "ninja"
    let fireballCategoryName = "fireball"
    let waterballCategoryName = "waterball"
    let floorCategoryName = "floor"
    let skyCategoryName = "sky"
    
    //Fireball Movements
    var moveAndRemove = SKAction()
    
    //Gamestate
    var fingerIsOnFireBall = false
    var fingerIsOnNinjaSide = false
    var gameStarted = false
    
    let JUMP_VELOCITY:CGFloat = 28

    override init(size: CGSize) {
        super.init(size:size)
        
        //Enable Contact
        self.physicsWorld.contactDelegate = self
        
        
        tapToPlay.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        tapToPlay.xScale = 1
        tapToPlay.yScale = 1
        tapToPlay.zPosition = 1
        self.addChild(tapToPlay)
        
        
        
        //Set Background Music
        let bgMusicURL: NSURL = NSBundle.mainBundle().URLForResource("beat1", withExtension: "mp3")!
        backgroundMusicPlayer = try! AVAudioPlayer(contentsOfURL: bgMusicURL)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        
        //Set Collision Sound
        let boomURL: NSURL = NSBundle.mainBundle().URLForResource("boom", withExtension: "mp3")!
        boom = try! AVAudioPlayer(contentsOfURL: boomURL)
        boom.prepareToPlay()
            
        //Set Background Image
        //let backgroundImage = SKSpriteNode(imageNamed: "bg")
        //backgroundImage.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        //self.addChild(backgroundImage)
        
        //Set Border
        let worldBorder = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0

        //Set Ninja Characteristics
        let ninja = SKSpriteNode(imageNamed: "ninja")
        ninja.name = ninjaCategoryName
        ninja.position = CGPointMake(self.frame.size.width/8, self.frame.size.height/2)
        ninja.color = SKColor.blackColor()
        ninja.xScale = 0.8
        ninja.yScale = 0.8
        self.addChild(ninja)
        ninja.physicsBody = SKPhysicsBody(circleOfRadius: ninja.frame.size.width/3)
        ninja.physicsBody?.friction = 0
        ninja.physicsBody?.affectedByGravity = false
        ninja.physicsBody?.allowsRotation = false
        
        //Set Fireball Characteristics
//        let fireball = SKSpriteNode(imageNamed: "fireball")
//        fireball.name = fireballCategoryName
//        fireball.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
//        fireball.xScale = 0.5
//        fireball.yScale = 0.5
//        //self.addChild(fireBall)
//        fireball.physicsBody = SKPhysicsBody(rectangleOfSize: fireball.size)
        
        //Set Floor
        let bottomRect = CGRectMake(self.frame.origin.x + 20, self.frame.origin.y, self.frame.size.width -  10, self.frame.size.height)
        let floor = SKNode()
        floor.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        self.addChild(floor)
        
        //Associate bitmasks to a name
        floor.physicsBody?.categoryBitMask = floorCategory
        ninja.physicsBody?.categoryBitMask = ninjaCategory
        //fireball.physicsBody?.categoryBitMask = fireballCategory
        
        //Ninja will be affected by fireball or floor
        ninja.physicsBody?.contactTestBitMask =  fireballCategory | floorCategory
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let initTouch = touches.first! as UITouch
        let initTouchLocation = initTouch.locationInNode(self)
        
        //Check if the game started
        if !gameStarted && initTouchLocation.x  < self.frame.width/2 {
            gameStarted = true
            tapToPlay.removeFromParent()
            boom.play()
            let spawn = SKAction.runBlock({
                () in
                self.createObstacles()
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayLoop = SKAction.repeatActionForever(spawnDelay)
            self.runAction(spawnDelayLoop)
            let distance = CGFloat( -self.frame.size.width)
            
            let moveFireballs = SKAction.moveByX(distance - 200, y: 0, duration: (3))
            
            let removeFireballs = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveFireballs, removeFireballs])
        
        }
        

        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(self)
        
        if touchLocation.x  < self.frame.width/2 && gameStarted {
            fingerIsOnNinjaSide = true
        } else if touchLocation.x  > self.frame.width/2 {
            
            let waterball:SKSpriteNode = SKSpriteNode(imageNamed: "waterball")
            let location:CGPoint = touch.locationInNode(self)

            
            if let ninja = self.childNodeWithName(ninjaCategoryName) {
            waterball.position = CGPoint(x: ninja.position.x + 40, y: ninja.position.y)
            }

            waterball.xScale = 0.1
            waterball.yScale = 0.1
            waterball.physicsBody = SKPhysicsBody(circleOfRadius: waterball.size.width/2)
            waterball.physicsBody?.categoryBitMask = waterballCategory
            waterball.physicsBody?.dynamic = true
            waterball.physicsBody?.usesPreciseCollisionDetection = true
            waterball.physicsBody?.contactTestBitMask = fireballCategory
            
            
            let offset:CGPoint = vecSub(location, b: waterball.position)
            
//            if ( offset.y < 0 ) {
//                return
//            }
//
            self.addChild(waterball)
            
            let direction:CGPoint = vecNormalize(offset)
            
            let shotLength:CGPoint = vecMulti(direction, b: 1000)
            
            let finalDestination:CGPoint = vecAdd(shotLength, b: waterball.position)
            
            let moveDuration:Float = Float(self.size.width) / Float(waterballVelocity)
            
            let move = SKAction.moveTo(finalDestination, duration: NSTimeInterval(moveDuration))
            let remove = SKAction.removeFromParent()
            
            
            waterball.runAction(SKAction.sequence([move,remove]))
        }

        if fingerIsOnNinjaSide {
            
            let ninja = self.childNodeWithName(ninjaCategoryName) as! SKSpriteNode
            ninja.physicsBody?.affectedByGravity = true
            for _: AnyObject in touches {
                ninja.physicsBody?.velocity =  CGVectorMake(0.0, 0.0)
                ninja.physicsBody?.applyImpulse(CGVectorMake(0, JUMP_VELOCITY))
                fingerIsOnNinjaSide = false
            }
        }
    }
    

    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        if firstBody.categoryBitMask == floorCategory && secondBody.categoryBitMask == fireballCategory {
            playerScoreLabel.fontColor = SKColor.greenColor()
            playerScore += 1
            print ("gucci")
        }
        
        if firstBody.categoryBitMask == ninjaCategory && secondBody.categoryBitMask == floorCategory {
            let lossScene = GameOverScene(size: self.size, playerWon: false)
            boom.play()
            backgroundMusicPlayer.stop()
            removeAllChildren()
            removeAllActions()
            self.view?.presentScene(lossScene)
            playerScore = 0
        }
        
        if firstBody.categoryBitMask == ninjaCategory && secondBody.categoryBitMask == fireballCategory {
            let lossScene = GameOverScene(size: self.size, playerWon: false)
            backgroundMusicPlayer.stop()
            removeAllChildren()
            removeAllActions()
            self.view?.presentScene(lossScene)
            playerScore = 0
        }
        
        if firstBody.categoryBitMask == waterballCategory && secondBody.categoryBitMask == fireballCategory {
            playerScoreLabel.fontColor = SKColor.redColor()
            playerScore += 1
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            
        }

    }
    
    override func didMoveToView(view: SKView) {
        
        playerScoreLabel = SKLabelNode(fontNamed: "Avenir-Black")
        playerScoreLabel.fontSize = 25
        playerScoreLabel.fontColor = SKColor.blackColor()
        playerScoreLabel.text = "Score: 0"
        playerScoreLabel.position = CGPointMake(self.frame.size.width - 100 ,self.frame.height - 20 )
        self.addChild(playerScoreLabel)
        
        
    }
    


    func createObstacles() {
        //Change score back to black
        playerScoreLabel.fontColor = SKColor.blackColor()
        
        let firePair = SKNode()
        let topFire = SKSpriteNode(imageNamed: "fireball")
        let bottomFire = SKSpriteNode(imageNamed: "fireball")
        
        var randomPosition = CGFloat(arc4random_uniform(160))
        
        topFire.name = fireballCategoryName
        topFire.xScale = 0.5
        topFire.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/10, center: CGPointMake(topFire.position.x - 30, topFire.position.y - 10))
        topFire.physicsBody?.dynamic = false
        topFire.position = CGPointMake(self.frame.size.width + 100, self.frame.size.height - 28 - randomPosition )
        
        topFire.physicsBody?.categoryBitMask = fireballCategory
        
        bottomFire.name = fireballCategoryName
        bottomFire.xScale = 0.5
        bottomFire.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/10, center: CGPointMake(bottomFire.position.x - 30, bottomFire.position.y - 10))
        bottomFire.physicsBody?.dynamic = false
        bottomFire.position = CGPointMake(self.frame.size.width + 100, self.frame.size.height - 28 -  randomPosition - 160)
        bottomFire.physicsBody?.categoryBitMask = fireballCategory
        
//        if let ninja = self.childNodeWithName(ninjaCategoryName) {
//            waterball.position = CGPoint(x: ninja.position.x + 40, y: ninja.position.y)
//        }
//        
//        waterball.xScale = 0.1
//        waterball.yScale = 0.1
//        waterball.physicsBody = SKPhysicsBody(circleOfRadius: waterball.size.width/2)
//        waterball.physicsBody?.categoryBitMask = waterballCategory
//        waterball.physicsBody?.dynamic = true
//        waterball.physicsBody?.usesPreciseCollisionDetection = true
//        waterball.physicsBody?.contactTestBitMask = fireballCategory
        
//        topFire.physicsBody?.contactTestBitMask = floorCategory
//        bottomFire.physicsBody?.contactTestBitMask = floorCategory
        firePair.physicsBody?.contactTestBitMask = floorCategory

        
        firePair.addChild(topFire)
        firePair.addChild(bottomFire)
        topFire.runAction(moveAndRemove)
        bottomFire.runAction(moveAndRemove)
        firePair.runAction(moveAndRemove)
        
        self.addChild(firePair)

    }
    
    
    func vecAdd(a:CGPoint, b:CGPoint)->CGPoint {
        return CGPointMake(a.x + b.x, a.y + b.y)
    }
    
    func vecSub(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    
    func vecMulti(a:CGPoint, b:CGFloat)->CGPoint{
        return CGPointMake(a.x * b, a.y * b)
    }
    
    func vecLength(a:CGPoint)->CGFloat{
        return CGFloat(sqrt(CGFloat(a.x)*CGFloat(a.x)+CGFloat(a.y)*CGFloat(a.y)))
    }
    
    func vecNormalize(a:CGPoint)->CGPoint{
        let length: CGFloat = vecLength(a)
        return CGPointMake(a.x / length, a.y / length)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
}
