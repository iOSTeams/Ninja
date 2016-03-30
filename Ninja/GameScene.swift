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

        var backgroundMusicPlayer = AVAudioPlayer()
        var boom = AVAudioPlayer()
    
        let ninjaCategory:UInt32 = 0x1 << 0
        let fireballCategory:UInt32 = 0x1 << 1
        let floorCategory:UInt32 = 0x1 << 2
        let SkyCategory:UInt32 = 0x1 << 3
        let waterballCategory:UInt32 = 0x1 << 4
        
        let ninjaCategoryName = "ninja"
        let fireballCategoryName = "fireBall"
        let waterballCategoryName = "waterBall"
        let floorCategoryName = "floor"
        let skyCategoryName = "sky"

        var moveAndRemove = SKAction()
        var gameStarted = false
    
        var fingerIsOnFireBall = false
        var fingerIsOnNinja = false
        var ninjaIsDynamic = false
    
        var ninja: SKSpriteNode = SKSpriteNode()
    

        override init(size: CGSize) {
            super.init(size:size)
            
            self.physicsWorld.contactDelegate = self
            
            //Set Background Music******************************************************************
            let bgMusicURL: NSURL = NSBundle.mainBundle().URLForResource("beat1", withExtension: "mp3")!
            backgroundMusicPlayer = try! AVAudioPlayer(contentsOfURL: bgMusicURL)
            backgroundMusicPlayer.numberOfLoops = -1
            
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
            
            let boomURL: NSURL = NSBundle.mainBundle().URLForResource("boom", withExtension: "mp3")!
            boom = try! AVAudioPlayer(contentsOfURL: boomURL)
            boom.prepareToPlay()
            
            
//          //Set Background Image
//          let backgroundImage = SKSpriteNode(imageNamed: "bg")
//          backgroundImage.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
//          self.addChild(backgroundImage)
            
            //Set Border Physics******************************************************************
            let worldBorder = SKPhysicsBody(edgeLoopFromRect: self.frame)
            self.physicsBody = worldBorder
            self.physicsBody?.friction = 0

            //Set Ninja Physics******************************************************************
            let ninja = SKSpriteNode(imageNamed: "ninja")
            ninja.name = ninjaCategoryName
            ninja.position = CGPointMake(self.frame.size.width/8, self.frame.size.height/2)
            ninja.color = SKColor.blackColor()
            self.addChild(ninja)
            ninja.physicsBody = SKPhysicsBody(circleOfRadius: ninja.frame.size.width/3)
            ninja.physicsBody?.friction = 0
            //ninja.physicsBody?.dynamic = ninjaIsDynamic
            ninja.physicsBody?.affectedByGravity = false
            //ninja.physicsBody?.applyImpulse(CGVectorMake(2, -2))
            ninja.physicsBody?.allowsRotation = false
            
            ninja.xScale = 0.8
            ninja.yScale = 0.8
            //Set Fireball Physics******************************************************************
            let fireBall = SKSpriteNode(imageNamed: "fireball")
            fireBall.name = fireballCategoryName
            fireBall.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
            //self.addChild(fireBall)
            fireBall.physicsBody = SKPhysicsBody(rectangleOfSize: fireBall.size)
            
            fireBall.xScale = 0.5
            fireBall.yScale = 0.5
            
            //Set floor physics******************************************************************
            let bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0.5)
            let floor = SKNode()
            floor.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
            self.addChild(floor)
            
            //collision************************************************************************************
            floor.physicsBody?.categoryBitMask = floorCategory
            ninja.physicsBody?.categoryBitMask = ninjaCategory
            fireBall.physicsBody?.categoryBitMask = fireballCategory
            
            
            
            ninja.physicsBody?.contactTestBitMask =  fireballCategory | floorCategory
        }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let initTouch = touches.first! as UITouch
        let initTouchLocation = initTouch.locationInNode(self)
        
        if !gameStarted && initTouchLocation.x  < self.frame.width/2 {
            gameStarted = true
            
            let spawn = SKAction.runBlock({
                () in
                self.createObstacles()
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayLoop = SKAction.repeatActionForever(spawnDelay)
            self.runAction(spawnDelayLoop)
            let distance = CGFloat( self.frame.width )
            
            let moveFireballs = SKAction.moveByX(-self.frame.size.width - 200, y: 0, duration: (3))
            //let moveFireballs = SKAction.moveTo(CGPointMake(0, 0), duration: 2)
            let removeFireballs = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveFireballs, removeFireballs])
        
        }
        

        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(self)
//        let body: SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
//        
//        if body?.node?.name == ninjaCategoryName {
//            print("ninja touched")
//            fingerIsOnNinja = true
//        } else if body?.node?.name == fireBallCategoryName {
//            print("fireball touched")
//            fingerIsOnFireBall = true
//        }
        
        
        if touchLocation.x  < self.frame.width/2 && gameStarted {
            fingerIsOnNinja = true
        } else if touchLocation.x  > self.frame.width/2 {
            
            let waterball:SKSpriteNode = SKSpriteNode(imageNamed: "waterball")
            let location:CGPoint = touch.locationInNode(self)
//            waterball.position = ninja.position
            
            if let ninja = self.childNodeWithName(ninjaCategoryName) {
            waterball.position = CGPoint(x: ninja.position.x + 40, y: ninja.position.y)
            }
//            CGPoint(x: ship.position.x, y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
            //waterball.position = /*ninja.position*/ CGPointMake(0, self.frame.size.height/2)
            waterball.xScale = 0.1
            waterball.yScale = 0.1
            
            waterball.physicsBody = SKPhysicsBody(circleOfRadius: waterball.size.width/2)
            waterball.physicsBody?.dynamic = true
            waterball.physicsBody?.contactTestBitMask = waterballCategory
            waterball.physicsBody?.contactTestBitMask = fireballCategory
            
            //waterball.physicsBody?.collisionBitMask = 0
            waterball.physicsBody?.contactTestBitMask = ninjaCategory
            //waterball.physicsBody?.collisionBitMask = 0
            waterball.physicsBody?.usesPreciseCollisionDetection = true

            
            var offset:CGPoint = vecSub(location, b: waterball.position)
            
//            if ( offset.y < 0 ) {
//                return
//            }
//            
            
            self.addChild(waterball)
            
            var direction:CGPoint = vecNormalize(offset)
            
            var shotLength:CGPoint = vecMulti(direction, b: 1000)
            
            var finalDestination:CGPoint = vecAdd(shotLength, b: waterball.position)
            
            let velocity = 581/1
            
            let moveDuration:Float = Float(self.size.width) / Float(velocity)
            
            
            
            let move = SKAction.moveTo(finalDestination, duration: NSTimeInterval(moveDuration))
            let remove = SKAction.removeFromParent()
            
            
            waterball.runAction(SKAction.sequence([move,remove]))
        }

        if fingerIsOnNinja {
            let ninja = self.childNodeWithName(ninjaCategoryName) as! SKSpriteNode
            ninja.physicsBody?.affectedByGravity = true
            for _: AnyObject in touches {
                ninja.physicsBody?.velocity =  CGVectorMake(0.0, 0.0)
                ninja.physicsBody?.applyImpulse(CGVectorMake(0, 50))
                fingerIsOnNinja = false
            }
        }
        
        //Play music
//        self.runAction(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
 
        
//        if fingerIsOnFireBall {
//            let touch = touches.first! as UITouch
//            let touchLocation = touch.locationInNode(self)
//            let prevTouchLocation = touch.previousLocationInNode(self)
//            let fireBall = self.childNodeWithName(fireBallCategoryName) as! SKSpriteNode
        
//            var newXPos = fireBall.position.x + (touchLocation.x - prevTouchLocation.x)
//            
//            newXPos = max(newXPos, fireBall.size.width/2)
//            newXPos = min(newXPos, self.size.width - fireBall.size.width/2)
//            
//            fireBall.position = CGPointMake(newXPos, fireBall.position.y)
//        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        //
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ninjaCategory && secondBody.categoryBitMask == floorCategory {
            print ("You lost")
            boom.play()
            backgroundMusicPlayer.stop()
            let lossScene = GameOverScene(size: self.size, playerWon: false)
            self.view?.presentScene(lossScene)
        }
        
        if firstBody.categoryBitMask == ninjaCategory && secondBody.categoryBitMask == fireballCategory {
            
            secondBody.node?.removeFromParent()
            print ("Burned")
            
            boom.play()
            backgroundMusicPlayer.stop()
            
            let lossScene = GameOverScene(size: self.size, playerWon: false)
            self.view?.presentScene(lossScene)
            
//            if isGameWon() {
//                let winScene = GameOverScene(size: self.size, playerWon: true)
//                self.view?.presentScene(winScene)
//            }
        }
        
        if firstBody.categoryBitMask == waterballCategory && secondBody.categoryBitMask == fireballCategory {
            print ("UAU")
  
        }
        
    }

    func createObstacles() {
        let firePair = SKNode()
        let topFire = SKSpriteNode(imageNamed: "fireball")
        let bottomFire = SKSpriteNode(imageNamed: "fireball")
        
        topFire.name = fireballCategoryName
        topFire.xScale = 0.5
        topFire.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/10, center: CGPointMake(topFire.position.x - 30, topFire.position.y - 10))
        topFire.physicsBody?.dynamic = false
        topFire.position = CGPointMake(self.frame.size.width + 100, self.frame.size.height/2)
        topFire.physicsBody?.categoryBitMask = fireballCategory
        
        bottomFire.name = fireballCategoryName
        bottomFire.xScale = 0.5
        bottomFire.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/10, center: CGPointMake(bottomFire.position.x - 30, bottomFire.position.y - 10))
        bottomFire.physicsBody?.dynamic = false
        bottomFire.position = CGPointMake(self.frame.size.width + 100, self.frame.size.height/4)
        bottomFire.physicsBody?.categoryBitMask = fireballCategory
        
        firePair.addChild(topFire)
        firePair.addChild(bottomFire)
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
        var length: CGFloat = vecLength(a)
        return CGPointMake(a.x / length, a.y / length)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
}
