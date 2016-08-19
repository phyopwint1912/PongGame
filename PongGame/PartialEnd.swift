//
//  PartialEnd.swift
//  PongGame
//
//  Created by Phyo Pwint  on 22/6/16.
//  Copyright © 2016 Phyo Pwint . All rights reserved.
//

import SpriteKit
import GameplayKit

class PartialEnd: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is Playing {
            let ball = scene.childNodeWithName(BallCategoryName) as! SKSpriteNode
            ball.physicsBody!.linearDamping = 1.0
            scene.physicsWorld.gravity = CGVectorMake(0, -9.8)
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is WaitingForTap.Type
    }
    
}