//
//  Playing.swift
//  PongGame
//
//  Created by Phyo Pwint  on 31/5/16.
//  Copyright © 2016 Phyo Pwint . All rights reserved.
//

import SpriteKit
import GameplayKit

class Playing: GKState {
    unowned let scene: GameScene
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is WaitingForTap {
            let ball = scene.childNodeWithName(BallCategoryName) as! SKSpriteNode
            if (scene.isMaster != nil && scene.isMaster == "true") {
                ball.physicsBody!.applyImpulse(CGVector(dx: scene.randomDirection(), dy: scene.randomDirection()))
            }
        }
    }
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        let ball = scene.childNodeWithName(BallCategoryName) as! SKSpriteNode
        scene.ballPosX = ball.position.x
        scene.ballPosY = ball.position.y

        let ballOriginX : CGFloat = 375
        let ballOriginY : CGFloat = 667
        
        if (scene.isMaster != nil && scene.isMaster == "false") {
            if (scene.posX != nil && scene.posY != nil) {
                let calculatePosition = CGPoint(x: scene.posX as! CGFloat - ballOriginX, y: scene.posY as! CGFloat - ballOriginY)
                let finalPosition = CGPoint(x: ballOriginX - calculatePosition.x, y: ballOriginY - calculatePosition.y)
                ball.position = CGPoint(x: finalPosition.x, y: finalPosition.y)
                ball.physicsBody!.restitution = 1
                ball.physicsBody!.friction = 0
                ball.physicsBody!.linearDamping = 0
                ball.physicsBody!.angularDamping = 0
            }
        }
        
        let maxSpeed: CGFloat = 600.0
        
        let xSpeed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx)
        let ySpeed = sqrt(ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
        
        let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
        
        if xSpeed <= 10.0 {
            if (scene.isMaster == "true") {
                ball.physicsBody!.applyImpulse(CGVector(dx: scene.randomDirection(), dy: 0.0))
            }
        }
        if ySpeed <= 10.0 {
            if (scene.isMaster == "true") {
                ball.physicsBody!.applyImpulse(CGVector(dx: 0.0, dy: scene.randomDirection()))
            }
        }
        
        if speed > maxSpeed {
            ball.physicsBody!.linearDamping = 0.4
        }
            
        else {
            ball.physicsBody!.linearDamping = 0.0
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is GameOver.Type
    }
    
}
