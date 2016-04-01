//
//  GameViewController.swift
//  Ninja
//
//  Created by King Justin on 3/29/16.
//  Copyright (c) 2016 justinleesf. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //override func viewWillLayoutSubviews() {
    
    override func viewDidLayoutSubviews() {
        let skView = self.view as! SKView
//
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        skView.showsPhysics = true
//        
        let gameScene = GameScene(size: skView.bounds.size)
        gameScene.backgroundColor =  SKColor.whiteColor()
        gameScene.scaleMode = .AspectFill
        
        skView.presentScene(gameScene)
        
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
