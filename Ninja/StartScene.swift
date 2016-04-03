//
//  StartScene.swift
//  Ninja
//
//  Created by King Justin on 4/1/16.
//  Copyright © 2016 justinleesf. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class StartScene: SKScene {
    var boom = AVAudioPlayer()
    let boomURL: NSURL = NSBundle.mainBundle().URLForResource("boom", withExtension: "mp3")!
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
        boom = try! AVAudioPlayer(contentsOfURL: boomURL)
        boom.prepareToPlay()
        boom.play()
        //let background = SKSpriteNode(imageNamed: "bg")
        //background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        //self.addChild(background)
        let startLabel = SKLabelNode(fontNamed: "Avenir-Black")
        startLabel.fontSize = 40
        startLabel.fontColor = SKColor.blackColor()
        startLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
        startLabel.text = "Start"
        self.addChild(startLabel)
        
        let tapToPlay: SKSpriteNode = SKSpriteNode(imageNamed: "tapToPlay")
        tapToPlay.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        tapToPlay.xScale = 2
        tapToPlay.yScale = 2
        tapToPlay.zPosition = 1
        self.addChild(tapToPlay)
        

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let breakOutGameScene = GameScene(size: self.size)
        self.view?.presentScene(breakOutGameScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
