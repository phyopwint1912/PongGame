//
//  GameOver.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Michael Briscoe on 1/16/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOver: GKState {
    unowned let scene: GameScene
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is Playing {
            let ball = scene.childNodeWithName(BallCategoryName) as! SKSpriteNode
            ball.alpha = 0
            //NSNotificationCenter.defaultCenter().postNotificationName("callInitialVC",  object: nil)
            //scene.disConnect()
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        //return false
        return stateClass is WaitingForTap.Type
    }
    
}
