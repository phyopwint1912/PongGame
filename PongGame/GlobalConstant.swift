//
//  GlobalConstant.swift
//  PongGame
//
//  Created by Phyo Pwint  on 22/6/16.
//  Copyright © 2016 Phyo Pwint . All rights reserved.
//

import Foundation
import UIKit


var gameStock : Int = 5
var Level1 : Int = 2
var Level2 : Int = 3
var Level3 : Int = 4

var speedBallFloat : CGFloat = 5.0

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let Paddle2CategoryName = "paddle2"
let GameMessageName = "gameMessage"
var BlockName = "block"
let LabelRound = "roundLabel"
let LabelPlayer1Mark = "Player1mark"
let LabelPlayer2Mark = "Player2mark"
let LabelPause = "PauseLabel"

struct CategoryOfBody {
    static let margin   :UInt32     = 0x1 << 0
    static let ball     :UInt32     = 0x1 << 1
    static let player   :UInt32     = 0x1 << 2
    static let block    :UInt32     = 0x1 << 3
}

var randomBlockX = CGFloat()
var randomBlockY = CGFloat()
let ButtonColor = UIColor(red: 25/255, green: 30/255, blue: 84/255, alpha: 1)


//                        let newScene = GameScene(fileNamed:"GameScene")
//                        newScene!.scaleMode = .AspectFit
//                        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//                        self.view?.presentScene(newScene!, transition: reveal)
